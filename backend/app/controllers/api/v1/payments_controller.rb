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

        redirect_url = "https://interisland-uninferrably-leonie.ngrok-free.app/api/v1/payments/success"
       
        
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
  # Limpia el carrito del usuario
  current_user.cart.cart_items.destroy_all if current_user&.cart

  # Cierra la ventana de Wompi
  render html: "<script>window.close()</script>".html_safe
end

    

    end
  end
end

