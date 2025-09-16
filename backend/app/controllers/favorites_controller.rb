class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorites = current_user.favorites.includes(:product)
  end

  def create
    favorite = current_user.favorites.create(product_id: params[:product_id])

    respond_to do |format|
      format.json { render json: { id: favorite.id }, status: :created }
      format.html { redirect_back fallback_location: root_path, notice: 'Agregado a favoritos' }
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
