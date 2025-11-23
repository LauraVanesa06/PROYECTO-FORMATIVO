module Api
  module V1 
    class PaymentsController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user!, only: [:create_checkout]
      require 'uri'



      def create_checkout
        amount_in_cents = params[:amount].to_i * 100
        reference = "PAYMENT-#{SecureRandom.hex(5)}"
        customer_email = params[:email]

          wompi = Rails.application.credentials.wompi

            public_key = wompi[:public_key]
         
            redirect_url = params[:redirect_url] || wompi[:redirect_url]

            encoded_redirect = URI.encode_www_form_component(redirect_url)

            raw = "#{reference}#{amount_in_cents}COP#{public_key}"
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

