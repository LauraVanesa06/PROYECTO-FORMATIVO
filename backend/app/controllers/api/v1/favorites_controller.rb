class Api::V1::FavoritesController < Api::V1::ApiController
  skip_before_action :authenticate_user_from_token!, only: [:create_checkout]

  def index
    return render json: { error: 'No autorizado' }, status: :unauthorized unless current_user
    
    begin
      favorites = current_user.favorite_products
      
      render json: favorites.map { |product|
        {
          id: product.id,
          nombre: product.nombre,
          descripcion: product.descripcion,
          precio: product.precio,
          imagen_url: product.images.attached? ? url_for(product.images.first) : nil
        }
      }
    rescue => e
      Rails.logger.error "Error en favorites#index: #{e.message}"
      render json: { error: 'Error interno del servidor' }, status: :internal_server_error
    end
  end

  def create
    return render json: { error: 'No autorizado' }, status: :unauthorized unless current_user

    product = Product.find_by(id: params[:product_id])
    unless product
      return render json: { error: 'Producto no encontrado' }, status: :not_found
    end

    favorite = current_user.favorites.find_or_create_by(product: product)

    render json: {
      message: 'Agregado a favoritos',
      product_id: favorite.product.id
    }, status: :created
  end

  def check
    is_favorite = current_user.favorites.exists?(product_id: params[:id])
    render json: { favorite: is_favorite }, status: :ok
  end


  def destroy
    favorite = current_user.favorites.find_by(product_id: params[:id])
    if favorite
      favorite.destroy
      render json: { message: 'Eliminado de favoritos' }, status: :ok
    else
      render json: { error: 'Producto no encontrado en favoritos' }, status: :not_found
    end
  end
end
