module Api
  module V1
    
      class PaymentsController < ApplicationController
        skip_before_action :verify_authenticity_token
        skip_before_action :authenticate_user!, only: [:create_checkout]


        def create_checkout
          amount_in_cents = params[:amount].to_i * 100
          reference = "PAYMENT-#{SecureRandom.hex(5)}"
          customer_email = params[:email] || "cliente@test.com"

          raw = "#{reference}#{amount_in_cents}COP#{ENV['WOMPI_PUBLIC_KEY']}#{ENV['WOMPI_REDIRECT_URL']}#{ENV['WOMPI_PRIVATE_KEY']}"
          integrity_signature = Digest::SHA256.hexdigest(raw)

          checkout_url = "https://checkout.wompi.co/p/?public-key=#{ENV['WOMPI_PUBLIC_KEY']}&currency=COP&amount-in-cents=#{amount_in_cents}&reference=#{reference}&signature=#{integrity_signature}&redirect-url=#{ENV['WOMPI_REDIRECT_URL']}"

          render json: { checkout_url: checkout_url }
        end
      end
  end
end

