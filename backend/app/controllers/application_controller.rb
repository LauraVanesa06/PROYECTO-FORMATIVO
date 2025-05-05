class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  def after_sign_in_path_for(resource)
    # Aquí defines la ruta a la que deseas redirigir
    # Puede ser una ruta nombrada como:
    dashboard_path # Por ejemplo, redirige a /productos
  end
end
