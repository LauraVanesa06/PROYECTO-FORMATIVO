class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_cart

  private

  def set_cart
    if user_signed_in?
      @cart = current_user.cart || current_user.create_cart
    else
      @cart = nil
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
