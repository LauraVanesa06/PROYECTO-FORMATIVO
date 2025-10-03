class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart

  def create
    product = Product.find(params[:product_id])
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
        format.json { render json: { success: true, item_id: @cart_item.id, quantity: @cart_item.cantidad, count: @cart_items.sum(&:cantidad) }, status: :created }
        format.html { redirect_to cart_path, notice: 'Producto agregado al carrito' }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: "No se pudo agregar el producto" }, status: :unprocessable_entity }
        format.html { redirect_to root_path, alert: 'No se pudo agregar el producto' }
      end
    end
  end

  def update
    @cart_item = @cart.cart_items.find(params[:id])
    
    if @cart_item.update(cart_item_params)
      @cart_items = @cart.cart_items.includes(:product)

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "cart_items",
            partial: "carts/cart_items",
            locals: { cart_items: @cart_items }
          )
        end
        format.json { render json: { success: true, item_id: @cart_item.id, quantity: @cart_item.cantidad }, status: :ok }
        format.html { redirect_to cart_path, notice: 'Cantidad actualizada.' }
      end
    else
      respond_to do |format|
        format.json { render json: { success: true, item_id: @cart_item.id, quantity: @cart_item.cantidad }, status: :ok }
        format.html { redirect_to cart_path, alert: 'Error al actualizar cantidad.' }
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
      format.json { render json: { success: true, deleted_id: @cart_item.id, count: @cart_items.sum(&:cantidad) }, status: :ok }
      format.html { redirect_to cart_path, notice: 'Producto eliminado del carrito' }
    end
  end

  private

  def set_cart
    @cart = current_user.cart
    
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity)
  end
end