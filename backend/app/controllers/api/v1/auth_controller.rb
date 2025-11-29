class Api::V1::AuthController < Api::V1::ApiController
  skip_before_action :authenticate_user_from_token!, only: [:login, :register]


  def login
    Rails.logger.info "Login params: #{params.inspect}"
    
    # Validar que se envíen email y password
    unless params[:email].present? && params[:password].present?
      return render json: {
        status: 'error',
        message: 'Email y contraseña son requeridos',
        error_code: 'MISSING_CREDENTIALS'
      }, status: :bad_request
    end

    # Validar formato de email
    unless params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
      return render json: {
        status: 'error',
        message: 'Formato de email inválido',
        error_code: 'INVALID_EMAIL_FORMAT'
      }, status: :bad_request
    end

    # Buscar usuario por email
    user = User.find_by(email: params[:email].downcase.strip)
    
    # Si no existe el usuario
    unless user
      return render json: {
        status: 'error',
        message: 'No existe una cuenta con este correo electrónico',
        error_code: 'USER_NOT_FOUND'
      }, status: :not_found
    end

    # Verificar si la cuenta está activa (si tienes ese campo)
    # if user.respond_to?(:active?) && !user.active?
    #   return render json: {
    #     status: 'error',
    #     message: 'Esta cuenta ha sido desactivada. Contacta al soporte.',
    #     error_code: 'ACCOUNT_DISABLED'
    #   }, status: :forbidden
    # end

    # Verificar contraseña
    unless user.valid_password?(params[:password])
      return render json: {
        status: 'error',
        message: 'Contraseña incorrecta',
        error_code: 'INVALID_PASSWORD'
      }, status: :unauthorized
    end

    # Login exitoso
    begin
      token = JsonWebToken.encode({ user_id: user.id })
      cart = user.cart || user.create_cart

      render json: {
        status: 'success',
        message: 'Inicio de sesión exitoso',
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          cart_id: user.cart.id
        }
      }
    rescue => e
      Rails.logger.error "Error en login: #{e.message}"
      render json: {
        status: 'error',
        message: 'Error al procesar el inicio de sesión',
        error_code: 'SERVER_ERROR'
      }, status: :internal_server_error
    end
  end

  def register
    # Validar que se envíen todos los campos requeridos
    unless params[:name].present? && params[:email].present? && params[:password].present?
      return render json: {
        status: 'error',
        message: 'Nombre, email y contraseña son requeridos',
        error_code: 'MISSING_FIELDS',
        errors: {
          name: params[:name].present? ? nil : 'El nombre es requerido',
          email: params[:email].present? ? nil : 'El email es requerido',
          password: params[:password].present? ? nil : 'La contraseña es requerida'
        }.compact
      }, status: :bad_request
    end

    # Validar formato de email
    unless params[:email].match?(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i)
      return render json: {
        status: 'error',
        message: 'Formato de email inválido',
        error_code: 'INVALID_EMAIL_FORMAT'
      }, status: :bad_request
    end

    # Verificar si el email ya está registrado
    if User.exists?(email: params[:email].downcase.strip)
      return render json: {
        status: 'error',
        message: 'Este correo electrónico ya está registrado',
        error_code: 'EMAIL_ALREADY_EXISTS'
      }, status: :conflict
    end

    # Validar longitud de contraseña
    if params[:password].length < 6
      return render json: {
        status: 'error',
        message: 'La contraseña debe tener al menos 6 caracteres',
        error_code: 'PASSWORD_TOO_SHORT'
      }, status: :bad_request
    end

    # Validar longitud del nombre
    if params[:name].strip.length < 2
      return render json: {
        status: 'error',
        message: 'El nombre debe tener al menos 2 caracteres',
        error_code: 'NAME_TOO_SHORT'
      }, status: :bad_request
    end

    # Crear usuario
    user = User.new(
      name: params[:name].strip,
      email: params[:email].downcase.strip,
      password: params[:password],
      role: params[:role] || 'user' # rol por defecto
    )
    
    if user.save
      begin
        token = JsonWebToken.encode({ user_id: user.id })
        
        render json: {
          status: 'success',
          message: 'Cuenta creada exitosamente',
          token: token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            cart_id: user.cart.id
          }
        }, status: :created
      rescue => e
        Rails.logger.error "Error generando token: #{e.message}"
        # Si falla el token, eliminar el usuario creado
        user.destroy
        render json: {
          status: 'error',
          message: 'Error al completar el registro',
          error_code: 'TOKEN_GENERATION_ERROR'
        }, status: :internal_server_error
      end
    else
      # Errores de validación de ActiveRecord
      error_messages = user.errors.full_messages
      
      render json: {
        status: 'error',
        message: error_messages.first || 'Error al crear la cuenta',
        error_code: 'VALIDATION_ERROR',
        errors: user.errors.messages
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
