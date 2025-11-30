class ApplicationController < ActionController::Base
    protect_from_forgery with: :null_session  # Necesario para APIs
  # ✅ Solo exigir login si no es Devise y no es el controlador de productos
  before_action :authenticate_user!, unless: :public_controller?

  # Solo navegadores modernos
  allow_browser versions: :modern

  before_action :set_cart
  before_action :load_cart_items  # 👈 agregado

  helper_method :current_cart     # 👈 para usar current_cart en vistas/partials

  before_action :set_locale

  private

  def public_controller?
    # Devise controllers (login, registro, etc.)
    return true if devise_controller?

    # Permitir ver productos sin login
    return true if controller_name == "products" && ["index", "show"].include?(action_name)

    false
  end

  def set_locale
    locale = params[:locale] || session[:locale] || I18n.default_locale
    locale = locale.to_sym
    I18n.locale = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
    session[:locale] = I18n.locale
  end

  # Para que TODOS los links mantengan ?locale= o /:locale
  def default_url_options
    { locale: I18n.locale }
  end

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
    # Siempre redirigir a home, sin importar el rol
    # Los admins pueden acceder al dashboard desde su perfil si lo desean
    authenticated_root_path
  end
  layout :layout_by_resource

    private

    def layout_by_resource
      if devise_controller?
        "login"
      else
        "application"
      end
    end

end
