class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  protect_from_forgery except: :webhook
  require 'faraday'
  require 'securerandom'

  def new
    @payment = Payment.new(cart: current_cart, amount: (current_cart.try(:total) || 0))
  end

  def status; end
  def checkout; end

  def webhook
    data = JSON.parse(request.body.read) rescue {}
    transaction = data.dig("data", "transaction") || {}

    payment = Payment.find_by(transaction_id: transaction["id"])

    if payment
      status = transaction["status"].to_s.downcase
      mapped_status = case status
                      when "approved", "confirmed" then :paid
                      when "declined", "failed" then :failed
                      when "cancelled" then :cancelled
                      else :pending
                      end

      payment.update(status: mapped_status)
    end


    @payment = Payment.find_by(transaction_id: transaction["id"])
    @payment.update(status: :paid)
    if @payment.status == "paid" && @payment.cart.present?
  Buy.create!(
    customer_id: @payment.user.customer.id,
    fecha: Time.current,
    tipo: "Minorista",
    metodo_pago: "Wompi",
    payment_id: @payment.id
  )
    head :ok
    
  end

  def create
    cart = current_cart || Cart.find_by(id: params[:cart_id])
    unless cart
      render json: { error: "Carrito no encontrado" }, status: :unprocessable_entity and return
    end

    amount_decimal = params[:amount].to_f
    amount_cents = (amount_decimal * 100).to_i
    currency = params[:currency] || "COP"
    pay_method = params[:pay_method] || "card"

    local_reference = params[:reference].presence || "local_payment_#{SecureRandom.hex(8)}_#{Time.now.to_i}"

    service = WompiService.new
    tokens = {}
    begin
      tokens = service.acceptance_tokens || {}
    rescue => e
      Rails.logger.error("[WompiService] acceptance_tokens error: #{e.message}")
    end

    payment = Payment.create!(
      cart: cart,
      amount: amount_decimal,
      currency: currency,
      status: 0,
      pay_method: pay_method,
      user_id: (params[:user_id] || current_user&.id),
      token: (tokens[:acceptance_token] || params[:token] || ""),
      account_info: (tokens[:personal_data_token] || params[:account_info] || ""),
      wompi_id: local_reference
    )

    payload = {
      amount_in_cents: amount_cents,
      currency: currency,
      customer_email: payment.user&.email || params[:email],
      reference: (params[:reference].presence || "payment_#{payment.id}_#{Time.now.to_i}"),
      redirect_url: params[:redirect_url] || "#{root_url}payments/#{payment.id}",
      acceptance_token: tokens[:acceptance_token]
    }

    url = "#{WompiService::BASE_URL}/transactions"
    resp = Faraday.post(url) do |req|
      req.headers['Authorization'] = "Bearer #{Rails.application.credentials.dig(:wompi, :private_key) || ENV['WOMPI_PRIVATE_KEY']}"
      req.headers['Content-Type'] = 'application/json'
      req.body = { transaction: payload }.to_json
    end

    unless resp.success?
      payment.update(status: "failed", raw_response: { error: resp.body })
      render json: { error: "Wompi request failed" }, status: :bad_gateway and return
    end

    body = JSON.parse(resp.body) rescue {}
    actual_wompi_id = body.dig("data", "id") || body.dig("data", "transaction", "id")
    checkout_url = body.dig("data", "authorization", "url") ||
                   body.dig("data", "transaction", "payment_method", "gateway_url") ||
                   body.dig("data", "metadata", "payment_link")

    payment.update(wompi_id: (actual_wompi_id || payment.wompi_id), raw_response: body)

    # Si la respuesta indica pago aprobado en línea, crear Buy ahora
    status = body.dig("data", "status") || body.dig("data", "transaction", "status")
    normalized_status = status.to_s.downcase
    if ["approved", "paid", "payment_successful"].include?(normalized_status)
      payment.update(status: "paid")
      create_buy_from_payment(payment)
    end

    render json: { payment_id: payment.id, wompi_id: actual_wompi_id, checkout_url: checkout_url, data: body }
  end

  # POST /payments/webhook
  def webhook
    payload = request.raw_post
    data = JSON.parse(payload) rescue {}
    transaction = data.dig("data", "transaction") || data.dig("data") || {}

    wompi_id = transaction["id"] || transaction.dig("transaction", "id")
    status = transaction["status"] || transaction.dig("transaction", "status") || data.dig("event", "name")

    payment = Payment.find_by(wompi_id: wompi_id) ||
              Payment.find_by("raw_response ->> 'reference' = ?", transaction["reference"]) rescue nil

    if payment
      payment.update(raw_response: payment.raw_response.to_h.merge(webhook: data))
      normalized_status = status.to_s.downcase
      if ["approved", "paid", "payment_successful"].include?(normalized_status)
        payment.update(status: "paid")
        create_buy_from_payment(payment)
      else
        payment.update(status: normalized_status) rescue nil
      end
    else
      Rails.logger.info("[WOMPI] webhook: payment not found for wompi_id=#{wompi_id} payload=#{payload}")
    end

    head :ok
  end

  def show
    @payment = Payment.find(params[:id])
    render json: { id: @payment.id, status: @payment.status, amount: @payment.amount, wompi_id: @payment.wompi_id }
  end

  def confirm
  @payment = Payment.find_by(transaction_id: params[:transaction_id])

  if @payment && @payment.status == "paid"
    customer = Customer.find_by(user_id: @payment.user_id)

    Buy.create!(
      customer: customer,
      fecha: Time.zone.now,
      tipo: "Online",
      metodo_pago: @payment.pay_method,
      payment: @payment
    )
  end
end

  private

  def payment_params
    params.permit(:pay_method, :cart_id, :amount, :account_info, :token, :reference)
  end

  def wompi_checkout_url(payment)
    pub_key = Rails.application.credentials.dig(:wompi, :public_key) || ENV['WOMPI_PUBLIC_KEY']
    "https://checkout.wompi.co/p/?public-key=#{pub_key}&amount-in-cents=#{(payment.amount.to_f * 100).to_i}&currency=COP&reference=#{payment.id}"
  end

  # Crea Buy y Purchasedetail desde el carrito asociado al payment (si aplica).
  def create_buy_from_payment(payment)
    return unless payment && payment.cart
    cart = payment.cart

    # evitar duplicados: comprobar si ya existe un Buy ligado a este payment (o por referencia)
    if defined?(Buy) && Buy.column_names.include?("payment_id")
      return if Buy.exists?(payment_id: payment.id)
    end

    ActiveRecord::Base.transaction do
      # construir atributos para Buy según columnas disponibles
      buy_attrs = {}
      buy_attrs[:customer_id] = payment.user.id if payment.user && Buy.column_names.include?("customer_id")
      buy_attrs[:fecha] = Time.current if Buy.column_names.include?("fecha")
      buy_attrs[:total] = (cart.total || 0) if Buy.column_names.include?("total")
      buy_attrs[:payment_id] = payment.id if Buy.column_names.include?("payment_id")

      buy = Buy.create!(buy_attrs)

      pd_cols = (defined?(Purchasedetail) ? Purchasedetail.column_names : [])

      cart.cart_items.each do |ci|
        detail_attrs = {}
        detail_attrs["buy_id"] = buy.id if pd_cols.include?("buy_id")

        product_id = ci.respond_to?(:product_id) ? ci.product_id : (ci.product&.id rescue nil)
        detail_attrs["product_id"] = product_id if product_id && pd_cols.include?("product_id")

        qty = (ci.respond_to?(:quantity) ? ci.quantity.to_i : (ci.respond_to?(:qty) ? ci.qty.to_i : 1))
        if pd_cols.include?("cantidad")
          detail_attrs["cantidad"] = qty
        elsif pd_cols.include?("quantity")
          detail_attrs["quantity"] = qty
        end

        price = (ci.respond_to?(:price) ? ci.price.to_f : (ci.product&.try(:precio) || 0)).to_f
        if pd_cols.include?("precio")
          detail_attrs["precio"] = price
        elsif pd_cols.include?("price")
          detail_attrs["price"] = price
        end

        total_line = price * qty
        if pd_cols.include?("total")
          detail_attrs["total"] = total_line
        elsif pd_cols.include?("subtotal")
          detail_attrs["subtotal"] = total_line
        end

        Purchasedetail.create!(detail_attrs)
      end

      # marcar carrito como completado si el modelo tiene campo o método
      if cart.respond_to?(:complete=)
        cart.update!(complete: true)
      elsif cart.respond_to?(:status=)
        cart.update!(status: "completed") rescue nil
      end

      # ligar buy id en payment si existe la columna
      if Payment.column_names.include?("buy_id")
        payment.update!(buy_id: buy.id)
      end
    end
  rescue => e
    Rails.logger.error("[Payments] create_buy_from_payment error: #{e.full_message}")
  end
end
