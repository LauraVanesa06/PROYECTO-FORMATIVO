class Api::V1::AuthController < Api::V1::ApiController
  skip_before_action :authenticate_user_from_token!, only: [:login, :register]


  def login
    Rails.logger.info "Login params: #{params.inspect}"
    
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      token = JsonWebToken.encode({ user_id: user.id })

      cart = user.cart || user.create_cart   

      render json: {
        status: 'success',
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          cart_id: user.cart.id
        } 
      }
    else
      render json: { 
        status: 'error',
        message: 'Credenciales inválidas' 
      }, status: :unauthorized
    end
  end

  def register
    user = User.new(register_params)
    
    if  user.save
      token = JsonWebToken.encode({ user_id: user.id })
      render json: {
        status: 'success',
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role
        }
      }, status: :created
    else
      render json: { 
        status: 'error',
        errors: user.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def me
    render json: {
      status: 'success',
      user: {
        id: @current_user.id,
        name: @current_user.name,
        email: @current_user.email,
        role: @current_user.role
      }
    }
  end

  def update
    if @current_user.update(update_params)
      render json: {
        status: 'success',
        message: 'Información actualizada correctamente',
        user: {
          id: @current_user.id,
          name: @current_user.name,
          email: @current_user.email,
          role: @current_user.role
        }
      }
    else
      render json: {
        status: 'error',
        message: 'Error al actualizar información',
        errors: @current_user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def change_password
    # Validar que se envíen los parámetros requeridos
    unless params[:current_password] && params[:new_password]
      return render json: {
        status: 'error',
        message: 'Faltan parámetros requeridos'
      }, status: :bad_request
    end

    # Verificar que la contraseña actual sea correcta
    unless @current_user.valid_password?(params[:current_password])
      return render json: {
        status: 'error',
        message: 'La contraseña actual es incorrecta'
      }, status: :unauthorized
    end

    # Intentar actualizar la contraseña
    if @current_user.update(password: params[:new_password])
      render json: {
        status: 'success',
        message: 'Contraseña actualizada correctamente'
      }
    else
      render json: {
        status: 'error',
        message: @current_user.errors.full_messages.first || 'Error al actualizar la contraseña',
        errors: @current_user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private


  def login_params
    params.permit(:email, :password)
  end

  def register_params
    params.permit(:name, :email, :password)
  end

  def update_params
    params.permit(:name, :email)
  end
end
