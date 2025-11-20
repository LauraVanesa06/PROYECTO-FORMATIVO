class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    
  def wompi
    payload = request.raw_post
    data = JSON.parse(payload) rescue {}
    event = data["data"] || {}

    wompi_id = event.dig("id") || event.dig("transaction", "id")
    status = event.dig("status") || event.dig("transaction", "status")

    payment = Payment.find_by(wompi_id: wompi_id)

    if payment.nil?
      ref = event.dig("reference") || event.dig("transaction", "reference")
      payment = Payment.find_by("raw_response ->> 'reference' = ?", ref) if ref
    end

    if payment
      payment.update(raw_response: payment.raw_response.merge(event: event))

      case status&.downcase
      when "approved", "paid"
        payment.update(status: "paid")

      unless Buy.exists?(payment_id: payment.id)
        Buy.create!(
          customer: Customer.find_by(user_id: payment.user_id),
          fecha: Time.zone.now,
          tipo: "Minorista",
          metodo_pago: "Wompi",
          total: payment.amount,
          payment: payment
        )
      end

        if (user = payment.user)
          PaymentMailer.with(user: user, payment: payment).invoice.deliver_now
        end

      when "pending"
        payment.update(status: "pending")

      when "declined", "failed"
        payment.update(status: "failed")
      end
    else
      Rails.logger.info("[WOMPI] Unknown payment webhook: #{payload}")
    end

    head :ok
  end
end