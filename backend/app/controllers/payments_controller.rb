class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook_return] 
  protect_from_forgery except: :webhook
  require 'faraday'

  def new
    @payment = Payment.new(
       cart: current_cart,
      amount: current_cart.total,

    
    )
  end

  def status
  end

  def checkout
  end



  def webhook
    data = JSON.parse(request.body.read)
    transaction = data["data"]["transaction"]

    payment = Payment.find_by(transaction_id: transaction["id"])
    if payment
      payment.update(status: transaction["status"])
    end

    head :ok
  end
def create
  # obtener/validar carrito
  cart = current_cart || Cart.find_by(id: params[:cart_id])
  unless cart
    render json: { error: "Carrito no encontrado" }, status: :unprocessable_entity
    return
  end

  # monto en decimal para el modelo, y en centavos para Wompi
  amount_decimal = params[:amount].to_f
  amount_cents = (amount_decimal * 100).to_i
  currency = params[:currency] || "COP"
  pay_method = params[:pay_method] || "card"

  # generar referencia local (se usa como valor inicial de wompi_id para evitar NULL)
  local_reference = "local_payment_#{SecureRandom.hex(8)}_#{Time.now.to_i}"

  # obtener tokens desde el servicio Wompi
  service = WompiService.new
  tokens = {}
  begin
    tokens = service.acceptance_tokens || {}
  rescue => e
    Rails.logger.error("[WompiService] acceptance_tokens error: #{e.message}")
  end

  # crear Payment con wompi_id temporal (no NULL)
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

  # preparar payload para Wompi usando el acceptance_token si lo tenemos
  payload = {
    amount_in_cents: amount_cents,
    currency: currency,
    customer_email: payment.user&.email || params[:email],
    reference: "payment_#{payment.id}_#{Time.now.to_i}",
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
    render json: { error: "Wompi request failed" }, status: :bad_gateway
    return
  end

  body = JSON.parse(resp.body) rescue {}
  actual_wompi_id = body.dig("data", "id") || body.dig("data", "transaction", "id")
  checkout_url = body.dig("data", "authorization", "url") || body.dig("data", "transaction", "payment_method", "gateway_url") || body.dig("data", "metadata", "payment_link")

  # actualizar wompi_id real y raw_response
  payment.update(wompi_id: (actual_wompi_id || payment.wompi_id), raw_response: body)

  render json: { payment_id: payment.id, wompi_id: actual_wompi_id, checkout_url: checkout_url, data: body }
end
 def show
    @payment = Payment.find(params[:id])
    render json: { id: @payment.id, status: @payment.status, amount: @payment.amount, wompi_id: @payment.wompi_id }
  end

  

private

def payment_params
  params.permit(:pay_method, :cart_id, :amount)
    params.permit(:pay_method, :account_info)
sche
end

  private

  def wompi_checkout_url(payment)
    pub_key = Rails.application.credentials.dig(:wompi, :public_key)

    "https://checkout.wompi.co/p/?public-key=#{pub_key}&amount-in-cents=#{(payment.amount * 100).to_i}&currency=COP&reference=#{payment.id}"
  end
end
