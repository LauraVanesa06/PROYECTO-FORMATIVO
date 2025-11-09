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
    qty = (params.dig(:cart_item, :quantity) || params.dig(:cart_item, :cantidad)).to_i
    qty = 1 if qty < 1

    if @cart_item.update(quantity: qty)
      # subtotal del item (usar el precio real del producto)
      product_price = (@cart_item.product&.precio || 0).to_f
      item_subtotal = product_price * (@cart_item.quantity || 1)

      # total del carrito recalculado en servidor (consistente)
      cart_total = @cart.cart_items.to_a.sum do |i|
        p = (i.product&.precio || 0).to_f
        q = (i.respond_to?(:quantity) ? i.quantity : (i.respond_to?(:cantidad) ? i.cantidad : 1)).to_i
        p * q
      end

      render json: {
        ok: true,
        item_id: @cart_item.id,
        item_subtotal: item_subtotal,
        cart_total: cart_total,
        count: @cart.cart_items.count
      }
    else
      render json: { ok: false, errors: @cart_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @cart_item = @cart.cart_items.find(params[:id])
    @cart_item.destroy
    cart_total = @cart.cart_items.to_a.sum { |i| (i.product&.precio || 0).to_f * (i.quantity || 1) }
    render json: { ok: true, cart_total: cart_total, count: @cart.cart_items.count }
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
    @cart = current_user&.cart || Cart.find_by(id: session[:cart_id])
  end

  def cart_item_params
    params.require(:cart_item).permit(:quantity, :cantidad)
  end
end
