class Api::V1::FavoritesController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!

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
