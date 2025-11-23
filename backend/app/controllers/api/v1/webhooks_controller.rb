module Api
  module V1
      
    class Api::V1::WebhooksController < ApplicationController
      skip_before_action :verify_authenticity_token

      def receive
        payload = JSON.parse(request.raw_post) rescue {}

        puts "Webhook recibido:"
        puts payload

        unless valid_webhook_signature?(payload)
          puts "firma invalida en webhooks"
          head :unauthorized and return
        end
          
          process_wompi_event(payload)

          head :ok
          
      end

      private

      def valid_webhook_signature?(payload)
        wompi_signature = payload.dig("signature", "checksum")
        return false unless wompi_signature

        properties = payload.dig("signature", "properties") || []
        transaction = payload.dig("data", "transaction")
        return false unless transaction
        raw = properties.map { |prop| prop.split('.').inject(transaction) { |obj, key| obj[key] } }.join

        secret = Rails.application.credentials.wompi[:secret] # O 'events' según tu credencial
        expected_signature = Digest::SHA256.hexdigest(raw + secret)

        wompi_signature == expected_signature
      end

      def process_wompi_event(payload)
        event_type = payload["event"]
        tx = payload.dig("data", "transaction")

        reference = tx["reference"]
        status = tx["status"]

        puts "Procesando evento #{event_type}..."
        puts "Referencia: #{reference}"
        puts  "Estado: #{status}"
    
        payment = Payment.find_by(reference: reference)
        if payment
          payment.update(status: status)
        else
          puts "No se encontró Payment con referencia #{reference}"
        end
    end
  end
end
