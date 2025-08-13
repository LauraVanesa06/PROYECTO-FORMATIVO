class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def create
    product = Product.find(params[:product_id])
    @cart_item = @cart.add_product(product.id)

    if @cart_item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cart_path, notice: 'Producto agregado al carrito' }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'No se pudo agregar el producto' }
      end
    end
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    if @cart_item.update(quantity: params[:quantity])
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to cart_path, notice: 'Cantidad actualizada' }
      end
    else
      respond_to do |format|
        format.html { redirect_to cart_path, alert: 'No se pudo actualizar la cantidad' }
      end
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to cart_path, notice: 'Producto eliminado del carrito' }
    end
  end

  private

  def set_cart
    @cart = current_user.cart
  end
end
