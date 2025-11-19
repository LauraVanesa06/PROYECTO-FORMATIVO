require 'json'

class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  skip_before_action :authenticate_user!, only: [:webhook]
  protect_from_forgery except: :webhook

  require 'securerandom'
  require 'faraday'

  ##########################################
  # 1) WIDGET TOKEN — CREA EL PAYMENT
  ##########################################
  def widget_token
    cart = current_user&.cart ||
           Cart.find_by(id: session[:cart_id]) ||
           Cart.find_by(id: params[:cart_id])

    unless cart&.cart_items&.any?
      render json: { error: 'Carrito no encontrado o vacío' }, status: :not_found and return
    end

    amount_in_cents =
      if params[:amount_in_cents].present?
        params[:amount_in_cents].to_i
      else
        (cart.cart_items.sum { |i| (i.product&.precio || 0) * (i.cantidad || 1) } * 100).to_i
      end

    reference = "cart_#{cart.id}_#{Time.now.to_i}"

    begin
      payment = Payment.create!(
        cart: cart,
        user: current_user,
        amount: amount_in_cents / 100.0,
        currency: "COP",
        reference: reference,
        status: "PENDING",
        raw_response: {}
      )
      Rails.logger.info "[PAGO] Payment creado con ID #{payment.id}"
    rescue => e
      Rails.logger.error "[PAGO][ERROR] Falló al crear Payment: #{e.message}"
      render json: { error: "Error creando el payment" }, status: :unprocessable_entity and return
    end

    signature = WompiService.new.signature_for(
      reference: reference,
      amount_in_cents: amount_in_cents,
      currency: 'COP'
    )

    render json: {
      public_key: Rails.application.credentials.dig(:wompi, :public_key),
      amount_in_cents: amount_in_cents,
      reference: reference,
      signature: signature
    }
  end

  ##########################################
  # 2) CREATE — USA EL PAYMENT CREADO
  ##########################################
  def create
    reference = params[:reference]
    payment = Payment.find_by(reference: reference)

    if payment.nil?
      render json: { error: "Referencia no encontrada" }, status: :not_found and return
    end

    cart = payment.cart
    amount_cents = (payment.amount * 100).to_i

    service = WompiService.new
    tokens = service.acceptance_tokens || {}

    payload = {
      amount_in_cents: amount_cents,
      currency: payment.currency,
      customer_email: payment.user.email,
      reference: payment.reference,
      redirect_url: "#{root_url}payments/#{payment.id}",
      acceptance_token: tokens[:acceptance_token]
    }

    url = "#{WompiService::BASE_URL}/transactions"
    resp = Faraday.post(url) do |req|
      req.headers['Authorization'] = "Bearer #{Rails.application.credentials.dig(:wompi, :private_key)}"
      req.headers['Content-Type'] = 'application/json'
      req.body = { transaction: payload }.to_json
    end

    unless resp.success?
      payment.update(status: "FAILED", raw_response: resp.body)
      render json: { error: "Wompi request failed", response: resp.body }, status: :bad_gateway and return
    end

    body = JSON.parse(resp.body) rescue {}

    payment.update!(
      wompi_id: body.dig("data", "id"),
      status: body.dig("data", "status"),
      raw_response: body
    )

    render json: {
      payment_id: payment.id,
      wompi_id: payment.wompi_id,
      checkout_url: body.dig("data", "authorization", "url")
    }
  end

  ##########################################
  # 3) WEBHOOK — CORREGIDO Y FUNCIONANDO
  ##########################################
  def webhook
    Rails.logger.info "[WOMPI] Webhook recibido: #{request.raw_post}"
    body = JSON.parse(request.raw_post) rescue {}

    transaction = body.dig("data", "transaction") || {}
    reference   = transaction["reference"]
    wompi_id    = transaction["id"]
    status      = transaction["status"]
    amount      = transaction["amount_in_cents"].to_f / 100.0 rescue 0

    normalized_status = status.to_s.upcase

    # 1️⃣ Buscar payment
    payment = Payment.find_by(reference: reference)

    # 2️⃣ Si no existe, crearlo
    if payment.nil?
      Rails.logger.warn "[WOMPI] Payment NO EXISTE. Creándolo con referencia #{reference}"

      cart_id = reference.split("_")[1].to_i
      cart = Cart.find_by(id: cart_id)

      payment = Payment.create!(
        reference: reference,
        cart: cart,
        user: cart&.user,
        amount: amount,
        currency: "COP",
        status: normalized_status,
        raw_response: {}
      )
    end

    # 3️⃣ Actualizar el pago
    payment.update!(
      wompi_id: wompi_id,
      status: normalized_status,
      raw_response: body,
      pay_method: transaction["payment_method_type"]
    )

    Rails.logger.info "[WOMPI] Payment actualizado #{payment.id} → #{normalized_status}"

    # 4️⃣ Si está aprobado, crear compra
    if ["APPROVED", "PAID", "PAYMENT_SUCCESSFUL"].include?(normalized_status)
      create_buy_from_payment(payment)
    end

    head :ok
  rescue => e
    Rails.logger.error "[WOMPI] Error webhook: #{e.full_message}"
    head :internal_server_error
  end

  ##########################################
  # 4) CREAR LA COMPRA
  ##########################################
  private

  def create_buy_from_payment(payment)
    cart = payment.cart
    return if Buy.exists?(payment_id: payment.id)

    ActiveRecord::Base.transaction do
      total_compra = cart.cart_items.sum { |i| (i.product&.precio || 0) * (i.cantidad || 1) }

      buy = Buy.create!(
        customer_id: payment.user.id,
        fecha: Time.current,
        tipo: "Online",
        metodo_pago: "Wompi",
        total: total_compra,
        payment_id: payment.id
      )

      cart.cart_items.each do |item|
        Purchasedetail.create!(
          buy_id: buy.id,
          product_id: item.product_id,
          cantidad: item.cantidad || 1,
          precio: item.product&.precio || 0,
          total: (item.product&.precio || 0) * (item.cantidad || 1)
        )
      end

      cart.cart_items.destroy_all

      payment.update!(buy_id: buy.id)
    end
  rescue => e
    Rails.logger.error("[Payments] Error creando compra: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
  end
end
