class CartsController < ApplicationController
  before_action :set_cart

  def show
    # Redirigir a home - el carrito ahora se muestra en el offcanvas
    redirect_to root_path
  end

  def payment_status
    @status = params[:status]
    render :payment_status
  end

  private

  def set_cart
    @cart =
      if current_user&.cart.present?
        current_user.cart
      elsif session[:cart_id]
        Cart.find_by(id: session[:cart_id])
      else
        nil
      end
  end
end

# Esto es necesario para responder a peticiones JSON desde el layout
# Ya que la ruta show redirige, necesitamos manejar JSON en otro lugar
class CartsController
  def show
    # Responder con JSON si es una petición AJAX
    if request.format.json?
      @cart_items = @cart.cart_items.includes(:product)

      total_amount = @cart_items.sum do |i|
        (i.product&.precio || 0) * i.cantidad.to_i
      end

      @amount_cents = (total_amount * 100).to_i
      @payment_reference = "cart_#{@cart.id}_#{Time.now.to_i}"

      @signature = WompiService.new.signature_for(
        reference: @payment_reference,
        amount_in_cents: @amount_cents
      )

      render json: { 
        total: total_amount,
        amount_cents: @amount_cents,
        payment_reference: @payment_reference,
        signature: @signature,
        public_key: Rails.application.credentials.dig(:wompi, :public_key),
        items_count: @cart_items.count
      }
    else
      # Redirigir a home para HTML
      redirect_to root_path
    end
  end
end
