class FavoritesController < ApplicationController
  before_action :authenticate_user_with_sidebar!, only: [:create, :destroy]

  def index
    @favorites = current_user.favorites.includes(:product)
  end

  def create
    product = Product.find(params[:product_id])
    
    # Permitir agregar a favoritos aunque no esté disponible
    favorite = current_user.favorites.find_or_initialize_by(product: product)

    if favorite.save
      respond_to do |format|
        format.json do
          render json: { 
            id: favorite.id, 
            message: "Producto agregado a favoritos",
            product_id: product.id
          }
        end
        format.html { redirect_back fallback_location: root_path, notice: "Producto agregado a favoritos" }
      end
    else
      respond_to do |format|
        format.json { render json: { error: "Error al agregar a favoritos" }, status: :unprocessable_entity }
        format.html { redirect_back fallback_location: root_path, alert: "Error al agregar a favoritos" }
      end
    end
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy

    respond_to do |format|
      format.json { render json: { success: true }, status: :ok }
      format.html { redirect_back fallback_location: root_path, notice: 'Eliminado de favoritos' }
    end
  end

  private

  def authenticate_user_with_sidebar!
    return if user_signed_in?

    respond_to do |format|
      # 🚀 Si viene de fetch() o AJAX, devolver JSON para que JS abra el sidebar
      format.json { render json: { show_login_sidebar: true }, status: :unauthorized }

      # 🚀 Si viene de HTML pero con cabecera de sidebar
      format.html do
        if request.headers["X-Requested-Sidebar"] == "true"
          render partial: "devise/sessions/form", layout: false
        else
          redirect_to new_user_session_path, alert: "Debes iniciar sesión para agregar productos a favoritos."
        end
      end
    end
  end
end