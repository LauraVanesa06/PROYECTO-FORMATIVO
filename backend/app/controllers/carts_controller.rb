class CartsController < ApplicationController
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:product)
    
    # Calcular monto total en centavos
    total_amount = @cart_items.sum { |item| (item.product&.precio || 0) * (item.cantidad || 0) }
    @amount_cents = (total_amount * 100).to_i
    
    # Generar referencia única
    @payment_reference = "orden_#{Time.current.to_i}"
    
    if @amount_cents > 0
      begin
        wompi_service = WompiService.new
        @signature = wompi_service.signature_for(
          reference: @payment_reference,
          amount_in_cents: @amount_cents
        )
      rescue => e
        Rails.logger.error("[Wompi] Error: #{e.message}")
        @signature = nil
      end
    end
  end

  private

  def set_cart
    @cart = current_user&.cart || Cart.find_by(id: session[:cart_id]) || Cart.create.tap { |c| session[:cart_id] = c.id }
  end
end
