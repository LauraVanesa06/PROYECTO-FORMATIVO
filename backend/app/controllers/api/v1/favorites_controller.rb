class Api::V1::FavoritesController < ApplicationController
  include Rails.application.routes.url_helpers
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!

  def index
    return render json: { error: 'No autorizado' }, status: :unauthorized unless @current_user
    
    begin
      favorites = @current_user.favorite_products
      
      render json: favorites.map { |product|
        {
          id: product.id,
          nombre: product.nombre,
          descripcion: product.descripcion,
          precio: product.precio,
          stock: product.stock,
          category_id: product.category_id,
          categoria: product.category&.nombre,
          imagen_url: product.images.attached? ? rails_blob_url(product.images.first) : "NO_IMAGE",
          has_images: product.images.attached?,
          images_count: product.images.count,
          favorito: true
        }
      }
    rescue => e
      Rails.logger.error "Error en favorites#index: #{e.message}"
      render json: { error: 'Error interno del servidor' }, status: :internal_server_error
    end
  end

  def create
    return render json: { error: 'No autorizado' }, status: :unauthorized unless @current_user

    product = Product.find_by(id: params[:product_id])
    unless product
      return render json: { error: 'Producto no encontrado' }, status: :not_found
    end

    favorite = @current_user.favorites.find_or_create_by(product: product)

    render json: {
      message: 'Agregado a favoritos',
      product_id: favorite.product.id
    }, status: :created
  end

  def check
    is_favorite = @current_user.favorites.exists?(product_id: params[:id])
    render json: { favorite: is_favorite }, status: :ok
  end


  def destroy
    favorite = @current_user.favorites.find_by(product_id: params[:id])
    if favorite
      favorite.destroy
      render json: { message: 'Eliminado de favoritos' }, status: :ok
    else
      render json: { error: 'Producto no encontrado en favoritos' }, status: :not_found
    end
  end

  private

  def authenticate_user_from_token!
    if request.headers['Authorization'].present?
      token = request.headers['Authorization'].split(' ').last
      begin
        payload = JsonWebToken.decode(token)
        @current_user = User.find_by(id: payload['user_id'])
        return render json: { error: 'Usuario no encontrado' }, status: :unauthorized unless @current_user
      rescue JWT::DecodeError
        render json: { error: 'Token inválido' }, status: :unauthorized
      end
    else
      render json: { error: 'Token no proporcionado' }, status: :unauthorized
    end
  end
end
