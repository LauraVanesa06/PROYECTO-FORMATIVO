class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def create
    product = Product.find(params[:product_id])

    # Buscar si ya existe este producto en el carrito
    @cart_item = @cart.cart_items.find_or_initialize_by(product: product)
    @cart_item.cantidad ||= 0
    @cart_item.cantidad += 1

    if @cart_item.save
      @cart_items = @cart.cart_items.includes(:product)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "cart_items",
              partial: "carts/cart_items",
              locals: { cart_items: @cart_items }
            ),
            turbo_stream.replace(
              "cart_count",
              partial: "carts/cart_count",
              locals: { count: @cart_items.sum(&:cantidad) }
            )
          ]
        end
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
    if @cart_item.update(cantidad: params[:cantidad]) # aquí usamos cantidad
      @cart_items = @cart.cart_items.includes(:product)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "cart_items",
            partial: "carts/cart_items",
            locals: { cart_items: @cart_items }
          )
        end
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

    @cart_items = @cart.cart_items.includes(:product)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "cart_items",
            partial: "carts/cart_items",
            locals: { cart_items: @cart_items }
          ),
          turbo_stream.replace(
            "cart_count",
            partial: "carts/cart_count",
            locals: { count: @cart_items.sum(&:cantidad) }
          )
        ]
      end
      format.html { redirect_to cart_path, notice: 'Producto eliminado del carrito' }
    end
  end

  private

  def set_cart
    @cart = current_user.cart
  end
end
