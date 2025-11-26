class CartsController < ApplicationController
  before_action :set_cart

  def show
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
