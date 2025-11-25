module Api
  module V1      
    class WebhooksController < Api::V1::ApiController
        skip_before_action :authenticate_user_from_token!
 

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

      def webhook
        data = params[:data][:transaction]
        reference = data[:reference]
        status = data[:status]

        payment = Payment.find_by(reference: reference)

        return head :not_found unless payment

        payment.update!(
          status: status,
          wompi_id: data[:id],
          pay_method: data[:payment_method_type],
          raw_response: params.to_json
        )

        if status == "APPROVED"
          process_successful_payment(payment)
        end

        head :ok
      end


      def process_successful_payment(payment)
        cart = payment.cart

        return unless cart

        cart.cart_items.each do |item|
          product = item.product
          product.update!(stock: product.stock - item.quantity)
        end

        cart.cart_items.destroy_all
      end



      private

      def valid_webhook_signature?(payload)
        wompi_signature = payload.dig("signature", "checksum")
        return false unless wompi_signature

        properties = payload.dig("signature", "properties") || []
        transaction = payload.dig("data", "transaction")
        return false unless transaction

        raw = properties.map { |prop|
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

        wompi_status = data["status"]

        mapped_status =
          case wompi_status
          when "APPROVED" then 1
          when "DECLINED" then 2
          when "ERROR"    then 3
          else 0 # PENDING
          end

        payment.update!(
          status: mapped_status,
          wompi_id: data["id"],
          pay_method: data["payment_method_type"],
          raw_response: raw
        )
      end
    end
  end
end
