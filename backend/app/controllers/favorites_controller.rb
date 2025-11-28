class FavoritesController < ApplicationController
  before_action :authenticate_user!

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
end
