require 'json'

class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  protect_from_forgery except: :webhook
  require 'securerandom'
  require 'faraday'
  # GET /payments/widget_token.json
  # Devuelve: { public_key, amount_in_cents, reference, signature }


 def webhook
  Rails.logger.info "[WOMPI] 🔔 Webhook recibido: #{request.raw_post}"
  body = JSON.parse(request.raw_post) rescue {}

  wompi_id = body.dig("data", "id")
  status = body.dig("data", "status") || body.dig("data", "transaction", "status")
  reference = body.dig("data", "reference")
  normalized_status = status.to_s.upcase

  Rails.logger.info "[WOMPI] Datos del webhook → ID: #{wompi_id}, Estado: #{normalized_status}, Referencia: #{reference}"

  payment = Payment.find_by(wompi_id: wompi_id)
  if payment.nil?
    Rails.logger.warn "[WOMPI] ⚠️ No se encontró Payment con wompi_id=#{wompi_id}"
    head :not_found and return
  end

  Rails.logger.info "[WOMPI] ✅ Pago encontrado (ID: #{payment.id}) con estado: #{normalized_status}"

  if ["APPROVED", "PAID", "PAYMENT_SUCCESSFUL"].include?(normalized_status)
    payment.update(status: "APPROVED")
    Rails.logger.info "[WOMPI] 💰 Estado actualizado a APPROVED"

    # 🔹 Intentamos enlazar con el carrito (o la compra) original
    if reference.present? && reference.start_with?("cart_")
      cart_id = reference.split("_")[1].to_i
      cart = Cart.find_by(id: cart_id)

      if cart
        Rails.logger.info "[WOMPI] 🛒 Carrito encontrado (ID: #{cart.id}), creando registro de compra..."

        # 🔹 Crear la compra si no existe aún
        buy = Buy.find_or_initialize_by(payment_id: payment.id)
        buy.customer_id = cart.customer_id
        buy.fecha = Time.current

        # Calculamos el total
        total = cart.cart_items.sum { |item| item.product.precio * item.quantity }
        buy.total = total

        if buy.save
          Rails.logger.info "[WOMPI] 🧾 Compra registrada correctamente (ID: #{buy.id}) con total: #{total}"

          # 🔹 Actualizamos el stock de los productos comprados
          cart.cart_items.each do |item|
            producto = item.product
            producto.update(stock: producto.stock - item.quantity)
          end
          Rails.logger.info "[WOMPI] 📦 Stock actualizado para los productos del carrito"

          # 🔹 Marcamos el carrito como completado (opcional)
          cart.update(status: "completed")
        else
          Rails.logger.error "[WOMPI] 🚫 Error al guardar la compra: #{buy.errors.full_messages.join(', ')}"
        end
      else
        Rails.logger.warn "[WOMPI] ⚠️ No se encontró carrito con ID #{cart_id} para la referencia #{reference}"
      end
    else
      Rails.logger.warn "[WOMPI] ⚠️ No se encontró referencia válida en el webhook"
    end
  else
    Rails.logger.info "[WOMPI] ❌ Estado no aprobado: #{normalized_status}"
  end

  head :ok
rescue => e
  Rails.logger.error "[WOMPI] 💥 Error procesando webhook: #{e.full_message}"
  head :internal_server_error
end

  def widget_token
    # Busca el carrito actual.
    cart = current_user&.cart || Cart.find_by(id: session[:cart_id]) || Cart.find_by(id: params[:cart_id])
    
    unless cart && cart.cart_items.any?
      render json: { error: 'Carrito no encontrado o vacío' }, status: :not_found and return
    end

    amount_in_cents = if params[:amount_in_cents].present?
                        params[:amount_in_cents].to_i
                      else
                        ((cart.cart_items.sum { |i| (i.product&.precio || 0) * (i.try(:cantidad) || i.try(:cantidad) || 1) }).to_f * 100).to_i
                      end

    reference = params[:reference].presence || "cart_#{cart.id}_#{Time.now.to_i}"

    begin
      signature = WompiService.new.signature_for(reference: reference, amount_in_cents: amount_in_cents, currency: 'COP')
    rescue => e
      Rails.logger.error("[Wompi] widget_token signature error: #{e.message}")
      render json: { error: 'No se pudo generar signature' }, status: :internal_server_error and return
    end

    public_key = Rails.application.credentials.dig(:wompi, :public_key) || ENV['WOMPI_PUBLIC_KEY']
    unless public_key.present?
      Rails.logger.error("[Wompi] public_key missing")
      render json: { error: 'Public key missing' }, status: :internal_server_error and return
    end

    render json: {
      public_key: public_key,
      amount_in_cents: amount_in_cents,
      reference: reference,
      signature: signature
    }
  end

  def new
    @payment = Payment.new(cart: current_cart, amount: (current_cart.try(:total) || 0))
  end

  def status; end
  def checkout; end

  
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
    response = service.create_card_transaction(
      reference: @reference,
      amount_in_cents: amount_cents,
      currency: currency,
      customer_email: current_user.email,
      token: params[:token],
    )
    transaction_data = response["data"]
    @payment = Payment.create!(
      user_id: current_user.id,
      amount: transaction_data["amount_in_cents"].to_f / 100,
      wompi_id: transaction_data["id"],
      status: transaction_data["status"],
      raw_response: transaction_data
    )
      redirect_to payment_path(@payment)
    tokens = {}
    begin
      tokens = service.acceptance_tokens || {}
    rescue => e
      Rails.logger.error("[WompiService] acceptance_tokens error: #{e.message}")
    end

    payment = Payment.create!(
      #  asocia el carrito actual
        cart: current_cart,  
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


  def show
    @payment = Payment.find(params[:id])
    render json: { id: @payment.id, status: @payment.status, amount: @payment.amount, wompi_id: @payment.wompi_id }
    @cart_items = current_user.cart.cart_items.includes(:product)
  total_amount = (@cart_items.sum(&:total_price) || 0).to_f

  @amount_cents = (total_amount * 100).to_i
  @payment_reference = params[:reference].presence || "cart_#{@cart&.id || 'anon'}_#{Time.now.to_i}"

  @signature = WompiService.new.signature_for(
    reference: @payment_reference,
    amount_in_cents: @amount_cents,
    currency: "COP"
  )
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

def create_buy_from_payment(payment)
  return unless payment && payment.cart
  cart = payment.cart

  # Evitar duplicados
  if defined?(Buy) && Buy.column_names.include?("payment_id")
    return if Buy.exists?(payment_id: payment.id)
  end

  ActiveRecord::Base.transaction do
    total_compra = cart.cart_items.sum { |i| (i.product&.precio || 0) * (i.try(:cantidad) || 1) }
    metodo = payment.pay_method.presence || "Wompi"

    buy = Buy.create!(
      customer_id: payment.user.id,
      fecha: Time.current,
      tipo: "Online",
      metodo_pago: metodo,
      total: total_compra,
      payment_id: payment.id
    )

    cart.cart_items.each do |item|
      Purchasedetail.create!(
        buy_id: buy.id,
        product_id: item.product_id,
        cantidad: item.cantidad || 1,
        precio: item.product&.precio || 0,
        total: (item.product&.precio || 0) * (item.try(:cantidad) || 1)
      )
    end

    cart.update!(status: "completed") if cart.respond_to?(:status=)
    cart.cart_items.destroy_all

    payment.update!(buy_id: buy.id)
  end

rescue => e
  Rails.logger.error("[Payments] create_buy_from_payment error: #{e.message}")
  Rails.logger.error(e.backtrace.join("\n"))
end

  def extract_cart_id_from_reference(reference)
    reference.split('_')[1].to_i
  rescue
    nil
  end
end