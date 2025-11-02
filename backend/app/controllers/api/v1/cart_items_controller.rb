class Api::V1::CartItemsController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!
  before_action :set_cart_item, only: [:update, :destroy]

  # GET /api/v1/cart_items
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

  # PATCH /api/v1/cart_items/:id
  def update
    case params[:quantity_action]
    when 'increase'
      @cart_item.increment!(:cantidad)
    when 'decrease'
      @cart_item.decrement!(:cantidad) if @cart_item.cantidad > 1
    end

    render json: @cart_item, status: :ok
  end

  # DELETE /api/v1/cart_items/:id
  def destroy
    @cart_item.destroy
    head :no_content
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

  def current_user
    @current_user
  end

  def set_cart_item
    @cart_item = CartItem.find_by(id: params[:id])

    unless @cart_item
      render json: { error: "Item no encontrado" }, status: :not_found and return
    end
  end
end

