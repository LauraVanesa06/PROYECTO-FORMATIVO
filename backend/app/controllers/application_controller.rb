class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_cart
  before_action :load_cart_items  # 👈 agregado

  helper_method :current_cart     # 👈 para usar current_cart en vistas/partials

  private

  # 👇 carrito actual (usuario o sesión)
  def current_cart
    if user_signed_in?
      current_user.cart || current_user.create_cart
    else
      cart = Cart.find_by(id: session[:cart_id])
      unless cart
        cart = Cart.create
        session[:cart_id] = cart.id
      end
      cart
    end
  end

  def set_cart
    @cart = current_cart
  end

  # 👇 siempre tener items disponibles para el layout/partial lateral
  def load_cart_items
    if @cart
      @cart_items = @cart.cart_items.includes(:product)
    else
      @cart_items = []
    end
  end

  def after_sign_in_path_for(resource)
    case resource.role
    when "admin"
      dashboard_path
    else
      authenticated_root_path
    end
  end
end
