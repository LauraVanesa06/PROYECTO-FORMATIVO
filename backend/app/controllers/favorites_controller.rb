class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @favorites = current_user.favorites.includes(:product)
  end

  def create
    product = Product.find(params[:product_id])
    current_user.favorites.find_or_create_by(product: product)
    redirect_back fallback_location: productos_path, notice: "Producto agregado a favoritos"
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy
    redirect_to favorites_path, notice: "Producto eliminado de favoritos."
  end
end
