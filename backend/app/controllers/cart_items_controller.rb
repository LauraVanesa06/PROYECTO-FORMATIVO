# frozen_string_literal: true

class CartItemsController < ApplicationController
  before_action :set_cart
  before_action :authenticate_user_with_sidebar!

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

        format.json do
          rendered_cart = render_to_string(
            partial: "carts/cart_items",
            locals: { cart_items: @cart_items },
            formats: [:html]
          )

          render json: {
            success: true,
            cart_html: rendered_cart,
            count: @cart_items.sum(&:cantidad)
          }, status: :created
        end

        format.html { redirect_to cart_path, notice: "Producto agregado al carrito" }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, error: "No se pudo agregar el producto" }, status: :unprocessable_entity }
        format.html { redirect_to root_path, alert: "No se pudo agregar el producto" }
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
        format.html { redirect_to cart_path, notice: "Cantidad actualizada." }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false }, status: :unprocessable_entity }
        format.html { redirect_to cart_path, alert: "Error al actualizar cantidad." }
      end
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy

    @cart_items = @cart.cart_items.includes(:product)

    respond_to do |format|
      format.turbo_stream
      format.json { render json: { success: true, count: @cart_items.sum(&:cantidad) }, status: :ok }
      format.html { redirect_to cart_path, notice: "Producto eliminado del carrito" }
    end
  end

  private

  # 🧩 Controla el acceso y muestra el sidebar si el usuario no está logueado
  def authenticate_user_with_sidebar!
    return if user_signed_in?

    respond_to do |format|
      # 🚀 Si viene de fetch() o AJAX, devolver JSON para que JS abra el sidebar
      format.json { render json: { show_login_sidebar: true }, status: :unauthorized }

      # 🚀 Si viene de HTML pero con cabecera de sidebar (fetch con headers especiales)
      format.html do
        if request.headers["X-Requested-Sidebar"] == "true"
          render partial: "devise/sessions/form", layout: false
        else
          redirect_to new_user_session_path, alert: "Debes iniciar sesión para agregar productos al carrito."
        end
      end
    end
  end

  def set_cart
    @cart = current_user&.cart || current_user&.create_cart || Cart.new
  end

  def cart_item_params
    params.require(:cart_item).permit(:cantidad)
  end
end
