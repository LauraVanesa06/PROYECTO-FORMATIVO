class Api::V1::CartItemsController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!

  def index
    return render json: { error: 'No autorizado' }, status: :unauthorized unless current_user
    
    begin
      cart = current_user.cart || current_user.create_cart
      cart_items = cart.cart_items.includes(:product)
      
      render json: cart_items.map { |item|
        {
          id: item.id,
          quantity: item.cantidad,
          product: {
            id: item.product.id,
            nombre: item.product.nombre,
            descripcion: item.product.descripcion,
            precio: item.product.precio,
            imagen_url: item.product.images.attached? ? url_for(item.product.images.first) : nil
          }
        }
      }
    rescue => e
      Rails.logger.error "Error en cart_items#index: #{e.message}"
      render json: { error: 'Error interno del servidor' }, status: :internal_server_error
    end
  end

  private

  def authenticate_user_from_token!
    token = request.headers['Authorization']&.split(' ')&.last
    return unless token

    payload = JsonWebToken.decode(token)
    @current_user = User.find_by(id: payload['user_id'])
  rescue JWT::DecodeError
    render json: { error: 'Token inválido' }, status: :unauthorized
  end
end
