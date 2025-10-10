class CartsController < ApplicationController
  before_action :set_cart
  before_action :authenticate_user!

  def show
    @cart = current_cart

    # calcular total robusto (decimal)
    total_amount = if @cart.respond_to?(:total) && @cart.total.present?
                     @cart.total.to_f
                   else
                     (@cart&.cart_items || []).sum { |i| (i.product&.precio || 0).to_f * (i.quantity || 0).to_i }
                   end

    amount_cents = (total_amount * 100).to_i

    # referencia única — usa la misma cuando crees la transacción en PaymentsController#create
    @payment_reference = "cart_#{@cart&.id || 'anon'}_#{Time.now.to_i}"

    # firma usando el integrity_secret
    begin
      @signature = WompiService.new.signature_for(
        reference: @payment_reference,
        amount_in_cents: amount_cents,
        currency: "COP"
      )
    rescue => e
      Rails.logger.error("[Wompi] signature error: #{e.message}")
      @signature = nil
    end

    @cart_items = @cart.cart_items
  end

  def add_item
    @cart = current_user.cart || current_user.create_cart
    product = Product.find(params[:product_id])
    item = @cart.cart_items.find_by(product_id: product.id)

    if item
      item.update(cantidad: item.cantidad + 1)
    else
      @cart.cart_items.create(product: product, cantidad: 1)
    end

    session[:cart_id] = @cart.id
    redirect_to cart_path, notice: "Producto agregado al carrito."
  end

  def update_item
    item = @cart.cart_items.find(params[:id])
    nueva_cantidad = params[:cantidad].to_i

    if nueva_cantidad > 0
      item.update(cantidad: nueva_cantidad)
    else
      item.destroy
    end

    redirect_to cart_path
  end

  def remove_item
    item = @cart.cart_items.find(params[:id])
    item.destroy
    redirect_to cart_path, notice: "Producto eliminado del carrito"
  end

  private

  def set_cart
    @cart = Cart.find_by(id: session[:cart_id]) || Cart.create
  end
end
