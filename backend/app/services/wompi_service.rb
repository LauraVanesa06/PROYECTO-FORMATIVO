# app/services/wompi_service.rb
require "net/http"
require "json"
require "digest"

class WompiService
  BASE_URL = "https://sandbox.wompi.co/v1".freeze

  def initialize
    @public_key       = Rails.application.credentials.dig(:wompi, :public_key) || ENV['WOMPI_PUBLIC_KEY']
    @private_key      = Rails.application.credentials.dig(:wompi, :private_key) || ENV['WOMPI_PRIVATE_KEY']
    @integrity_secret = Rails.application.credentials.dig(:wompi, :integrity_secret) || ENV['WOMPI_INTEGRITY_SECRET']
  end

  # 1) Obtener tokens de aceptación (política y datos personales)
  def acceptance_tokens
    uri = URI("#{BASE_URL}/merchants/#{@public_key}")
    res = Net::HTTP.get_response(uri)
    data = JSON.parse(res.body)
    {
      acceptance_token:     data.dig("data", "presigned_acceptance", "acceptance_token"),
      personal_data_token:  data.dig("data", "presigned_personal_data_auth", "acceptance_token") # puede venir nil en sandbox
    }
  end

  # 2) Generar firma: SHA256( reference + amount_in_cents + currency + integrity_secret )
  def signature_for(reference:, amount_in_cents:, currency: "COP")
    raise "Wompi integrity_secret missing" if @integrity_secret.blank?
    
    # Concatenar en orden correcto
    payload = "#{reference}#{amount_in_cents}#{currency}#{@integrity_secret}"
    
    # Generar hash SHA256
    OpenSSL::Digest::SHA256.hexdigest(payload)
  end


  # 3) Crear transacción con tarjeta tokenizada
  def create_card_transaction(reference:, amount_in_cents:, customer_email:, token:, installments: 1)
    tokens = acceptance_tokens

    body = {
      amount_in_cents:  amount_in_cents,
      currency:         "COP",
      reference:        reference,
      customer_email:   customer_email,
      acceptance_token: tokens[:acceptance_token],
      payment_method: {
        type:        "CARD",
        token:       token,
        installments: installments
      },
      signature: signature_for(reference: reference, amount_in_cents: amount_in_cents)
    }

    # Opcional: si tu cuenta exige este segundo token, lo agregas
    body[:accept_personal_auth] = tokens[:personal_data_token] if tokens[:personal_data_token].present?

    uri = URI("#{BASE_URL}/transactions")
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{@public_key}"     # OJO: aquí va la PUBLIC KEY
    req["Content-Type"]  = "application/json"
    req.body = body.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    JSON.parse(res.body)
  end

  # 4) Consultar una transacción por ID
  def fetch_transaction(id)
    uri = URI("#{BASE_URL}/transactions/#{id}")
    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body)
  end

  # 5) Tokenizar tarjeta (opcional, si no usas el widget de Wompi)
  def tokenize_card(card_number:, exp_month:, exp_year:, cvv:, card_holder:)
    uri = URI("#{BASE_URL}/tokens/cards")
    body = {
      number: card_number,
      exp_month: exp_month,
      exp_year: exp_year,
      cvc: cvv,
      card_holder: card_holder
    }
    req = Net::HTTP::Post.new(uri)
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{@public_key}"
    req.body = body.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
    JSON.parse(res.body)
  end

end