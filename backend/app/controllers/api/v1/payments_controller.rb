module Api
  module V1 
    class PaymentsController <  Api::V1::ApiController
     skip_before_action :authenticate_user_from_token!, only: [:create_checkout]

      require 'uri'



      def create_checkout
        amount_in_cents = params[:amount].to_i * 100
        reference = "PAYMENT-#{SecureRandom.hex(5)}"

        wompi = Rails.application.credentials.wompi
        public_key = wompi[:public_key]
        integrity_secret = wompi[:integrity_secret]

        redirect_url = params[:redirect_url] || wompi[:redirect_url]
        encoded_redirect = URI.encode_www_form_component(redirect_url)

        # Firma correcta
        raw = "#{reference}#{amount_in_cents}COP#{integrity_secret}"
        integrity_signature = Digest::SHA256.hexdigest(raw)

        checkout_url = "https://checkout.wompi.co/p/?" \
                      "public-key=#{public_key}" \
                      "&currency=COP" \
                      "&amount-in-cents=#{amount_in_cents}" \
                      "&reference=#{reference}" \
                      "&signature=#{integrity_signature}" \
                      "&redirect-url=#{encoded_redirect}"

        render json: { 
          checkout_url: checkout_url,
          reference: reference 
        }
      end


    end
  end
end

