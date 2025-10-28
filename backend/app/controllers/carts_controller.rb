class CartsController < ApplicationController
  before_action :set_cart

  def show
    Rails.logger.info "[DEBUG Wompi] Firma generada: #{@signature}"
    @cart_items = @cart.cart_items.includes(:product)
    total_amount = @cart_items.sum { |i| (i.product&.precio || 0) * (i.try(:cantidad) || i.try(:quantity) || 1) }.to_f
    @amount_cents = (total_amount * 100).to_i
    @payment_reference = params[:reference].presence || "cart_#{@cart&.id || 'anon'}_#{Time.now.to_i}"
    begin
      @signature = WompiService.new.signature_for(reference: @payment_reference, amount_in_cents: @amount_cents, currency: 'COP')
    rescue => e
      Rails.logger.error("[Wompi] signature error in carts#show: #{e.message}")
      @signature = nil
    end
  end

  private

  def set_cart
    @cart = current_user&.cart || Cart.find_by(id: session[:cart_id]) || Cart.create.tap { |c| session[:cart_id] = c.id }
  end
end
