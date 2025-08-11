class CartItemsController < ApplicationController
  before_action :authenticate_user! # Requiere login

  def create
    @cart = current_cart
    @product = Product.find(params[:product_id])
    @cart.add_product(@product)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) } # vuelve a la página anterior
    end
  end


  def destroy
    cart = current_user.cart
    item = cart.cart_items.find(params[:id])
    item.destroy
    redirect_to cart_path
  end
end
