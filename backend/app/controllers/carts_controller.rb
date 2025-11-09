class CartsController < ApplicationController
  before_action :set_cart

  def show
    @cart_items = @cart.cart_items.includes(:product)
    total_amount = @cart_items.sum { |i| (i.product&.precio || 0) * (i.respond_to?(:cantidad) ? i.cantidad.to_i : i.quantity.to_i) }
    @amount_cents = (total_amount * 100).to_i
    @payment_reference = "cart_#{@cart.id}_#{Time.now.to_i}"
    @signature = WompiService.new.signature_for(reference: @payment_reference, amount_in_cents: @amount_cents) rescue nil
  end
def payment_status
  @status = params[:status]
  render :payment_status
end

  private

  def set_cart
    @cart = current_user&.cart || Cart.find(session[:cart_id]) rescue nil
  end
end
