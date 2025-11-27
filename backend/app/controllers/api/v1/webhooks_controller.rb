module Api
  module V1
    class WebhooksController < ActionController::API
      skip_before_action :verify_authenticity_token

      def receive
        payload = JSON.parse(request.raw_post) rescue {}
        puts "Webhook recibido:"
        puts payload

        return head :unauthorized unless valid_webhook_signature?(payload)

        process_wompi_event(payload)
        head :ok
      end

      private

      def valid_webhook_signature?(payload)
        wompi_signature = payload.dig("signature", "checksum")
        return false unless wompi_signature

        properties = payload.dig("signature", "properties") || []
        tx = payload.dig("data", "transaction")
        return false unless tx

        raw = properties.map { |prop|
          prop.split(".").inject(tx) { |obj, key| obj[key] }
        }.join

        secret = Rails.application.credentials.wompi[:events_secret]
        expected = Digest::SHA256.hexdigest(raw + secret)

        wompi_signature == expected
      end

      def process_wompi_event(payload)
        tx = payload.dig("data", "transaction")
        reference = tx["reference"]
        status = tx["status"]

        payment = Payment.find_by(reference: reference)
        return puts "⚠️ Payment no encontrado" unless payment

        payment.update!(status: status)

        return unless status == "APPROVED"

        cart = payment.cart
        return unless cart.present?

        cart.cart_items.each do |item|
          product = item.product
            next unless product
          new_stock = [product.stock - item.cantidad, 0].max
          product.update!(stock: new_stock)
        end

        cart.cart_items.destroy_all
          cart.update!(completed: true)
      end
    end
  end
end
