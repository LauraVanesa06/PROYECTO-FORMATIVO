module Api
  module V1      
    class WebhooksController < ActionController::API
      skip_before_action :verify_authenticity_token

      def receive
        payload = JSON.parse(request.raw_post) rescue {}

        puts "Webhook recibido:"
        puts payload

        unless valid_webhook_signature?(payload)
          puts "Firma inválida"
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

        raw = properties.map { |prop|)
          prop.split('.').inject(transaction) { |obj, key| obj[key] }
        }.join

        secret = Rails.application.credentials.wompi[:events_secret]
        
        expected_signature = Digest::SHA256.hexdigest(raw + secret)
        wompi_signature == expected_signature
      end

      def process_wompi_event(payload)
        tx = payload.dig("data", "transaction")
        reference = tx["reference"]
        status = tx["status"]

        puts "Referencia: #{reference}"
        puts "Estado: #{status}"

        if (payment = Payment.find_by(reference: reference))
          payment.update(status: status)
        else
          puts "No existe Payment con esa referencia"
        end
      end
    end
  end
end
