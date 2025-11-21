module Api
  module V1
    module Payments
      class CheckoutController < ApplicationController

        def create_checkout
          amount_in_cents = params[:amount].to_i * 100
          reference = "PAYMENT-#{SecureRandom.hex(5)}"
          customer_email = params[:email] || "cliente@test.com"

          raw = "#{reference}#{amount_in_cents}COP#{ENV['WOMPI_PUBLIC_KEY']}#{ENV['WOMPI_REDIRECT_URL']}#{ENV['WOMPI_PRIVATE_KEY']}"
          integrity_signature = Digest::SHA256.hexdigest(raw)

          html = <<~HTML
            <!doctype html>
            <html>
            <head><meta charset="utf-8"><title>Checkout</title></head>
            <body>
              <script src="https://checkout.wompi.co/v1/checkout.js"></script>
              <script>
                const checkout = new WidgetCheckout({
                  currency: "COP",
                  amountInCents: #{amount_in_cents},
                  publicKey: "#{ENV['WOMPI_PUBLIC_KEY']}",
                  reference: "#{reference}",
                  customerEmail: "#{customer_email}",
                  redirectUrl: "#{ENV['WOMPI_REDIRECT_URL']}",
                  integritySignature: "#{integrity_signature}"
                });

                checkout.open();
              </script>

              <p>Si no ves el popup, haz clic aquí:
                <a href="#" onclick="checkout.open()">Abrir pago</a>
              </p>
            </body>
            </html>
          HTML

          render html: html.html_safe
        end

      end
    end
  end
end
module Api
  module V1
    module Payments
class Api::V1::PaymentsCheckoutController < ApplicationController
 
  def create_checkout
    amount_in_cents = params[:amount].to_i * 100
    reference = "PAYMENT-#{SecureRandom.hex(5)}"
    customer_email = params[:customer_email]

    raw = "#{reference}#{amount_in_cents}COP#{ENV['WOMPI_PUBLIC_KEY']}#{ENV['WOMPI_REDIRECT_URL']}#{ENV['WOMPI_PRIVATE_KEY']}"
    
    integrity_signature = Digest::SHA256.hexdigest(raw)

    html = <<~HTML
      <!doctype html>
      <html>
      <head><meta charset="utf-8"><title>Checkout</title></head>
      <body>
        <script src="https://checkout.wompi.co/v1/checkout.js"></script>
        <script>
          const checkout = new WidgetCheckout({
            currency: "COP",
            amountInCents: #{amount_in_cents},
            publicKey: "#{PUBLIC_KEY}",
            reference: "#{reference}",
            customerEmail: "#{customer_email}",
            redirectUrl: "#{REDIRECT_URL}",
            integritySignature: "#{integrity_signature}"
          });

          checkout.open();
        </script>

        <p>Si no ves el popup, haz clic aquí:
          <a href="#" onclick="checkout.open()">Abrir pago</a>
        </p>
      </body>
      </html>
    HTML

    render html: html.html_safe
  end
  
end
