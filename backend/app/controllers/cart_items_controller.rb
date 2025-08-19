class CartItemsController < ApplicationController
  before_action :authenticate_user! # Requiere login

  def create
    cart = current_user.cart
    product = Product.find(params[:product_id])

    item = cart.cart_items.find_by(product: product)

    if item
      item.increment!(:quantity)
    else
      cart.cart_items.create(product: product, quantity: 1)
    end

    redirect_to cart_path
  end

  def destroy
    cart = current_user.cart
    item = cart.cart_items.find(params[:id])
    item.destroy
    redirect_to cart_path
  end
end
