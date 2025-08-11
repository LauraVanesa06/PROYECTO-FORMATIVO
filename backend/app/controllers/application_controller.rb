class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_cart
  before_action :load_cart_items  # 👈 agregado

  private

  def set_cart
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
    else
      @cart = nil
    end
  end

  # 👇 agregado para que siempre tengamos los items disponibles
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

