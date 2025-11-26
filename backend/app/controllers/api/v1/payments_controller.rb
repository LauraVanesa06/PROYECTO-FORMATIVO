module Api
  module V1 
    class PaymentsController <  ActionController::API
    # skip_before_action :authenticate_user_from_token!, only: [:create_checkout]
    #protect_from_forgery with: :null_session
    #skip_before_action :verify_authenticity_token
      require 'uri'

      def create_checkout
        raw_amount = params[:amount].to_i
        amount_in_cents = raw_amount > 100000 ? raw_amount : raw_amount * 100
        reference = "PAYMENT-#{SecureRandom.hex(5)}"

        wompi = Rails.application.credentials.wompi
        public_key = wompi[:public_key]
        integrity_secret = wompi[:integrity_secret]

        redirect_url = "https://interisland-uninferrably-leonie.ngrok-free.dev/api/v1/payments/success"
       
        
        encoded_redirect = URI.encode_www_form_component(redirect_url)


        cart = Cart.find(params[:cart_id])
        user = cart.user

        Payment.create!(
          reference: reference,
          amount: amount_in_cents,
         user: user,
          cart: cart,
          status: "pending",
        )


        # Firma de integridad
         raw = "#{reference}#{amount_in_cents}COP#{integrity_secret}"
        integrity_signature = Digest::SHA256.hexdigest(raw)

        checkout_url = "https://checkout.wompi.co/p/?" \
                       "public-key=#{public_key}" \
                       "&currency=COP" \
                       "&amount-in-cents=#{amount_in_cents}" \
                       "&reference=#{reference}" \
                       "&signature:integrity=#{integrity_signature}" \
                       "&redirect-url=#{encoded_redirect}"

        render json: {
          checkout_url: checkout_url,
          reference: reference
         }
      end

      def success
        cart_id = params[:cart_id]
        user_id = params[:user_id]

        if cart_id
          cart = Cart.find_by(id: cart_id)
          cart&.cart_items&.destroy_all
        elsif user_id
          user = User.find_by(id: user_id)
          user&.cart&.cart_items&.destroy_all
        end

        # Devolver HTML de éxito para mostrar en WebView
        render html: <<~HTML.html_safe
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Pago Exitoso</title>
            <style>
              body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                margin: 0;
                background: linear-gradient(135deg, #2e67a3 0%, #1a4d7a 100%);
                padding: 20px;
              }
              .container {
                background: white;
                border-radius: 20px;
                padding: 40px;
                text-align: center;
                box-shadow: 0 10px 40px rgba(0,0,0,0.2);
                max-width: 400px;
                width: 100%;
              }
              .success-icon {
                width: 80px;
                height: 80px;
                background: #4CAF50;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 20px;
                animation: scaleIn 0.5s ease-out;
              }
              .checkmark {
                color: white;
                font-size: 48px;
                font-weight: bold;
              }
              h1 {
                color: #2e67a3;
                margin: 20px 0 10px;
                font-size: 24px;
              }
              p {
                color: #666;
                line-height: 1.6;
                margin: 10px 0;
              }
              .auto-close {
                color: #999;
                font-size: 14px;
                margin-top: 20px;
              }
              @keyframes scaleIn {
                from { transform: scale(0); }
                to { transform: scale(1); }
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="success-icon">
                <span class="checkmark">✓</span>
              </div>
              <h1>¡Pago Exitoso!</h1>
              <p>Tu compra se ha procesado correctamente.</p>
              <p>El carrito ha sido vaciado.</p>
              <p class="auto-close">Esta ventana se cerrará automáticamente...</p>
            </div>
          </body>
          </html>
        HTML
      end

    

    end
  end
end

