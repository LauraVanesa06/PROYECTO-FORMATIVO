class Usuarios::PasswordsController < Devise::PasswordsController
  layout 'custom_login'
  skip_before_action :verify_authenticity_token, only: [:create, :update]
  respond_to :html, :json

  # POST /users/password
  def create
    # Verificar primero si el email existe
    if request.format.json?
      email = params.dig(:user, :email)
      user = User.find_by(email: email)
      
      if user.nil?
        return render json: { 
          error: 'Este correo no está registrado' 
        }, status: :not_found
      end
      
      # Generar código de 6 dígitos
      codigo = rand(100000..999999).to_s
      
      # Guardar el código en el usuario
      user.update(
        recovery_code: codigo,
        recovery_code_sent_at: Time.current
      )
      
      # Enviar el correo con el código personalizado
      PasswordResetMailer.reset_code_email(user, codigo).deliver_now
      
      return render json: { 
        message: 'Código de verificación enviado a tu correo',
        reset_token: codigo
      }, status: :ok
    end

    self.resource = resource_class.send_reset_password_instructions(resource_params)
    
    if successfully_sent?(resource)
      if request.format.json?
        render json: { 
          message: 'Instrucciones de recuperación enviadas a tu correo',
        }, status: :ok
      else
        respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      end
    else
      if request.format.json?
        render json: { 
          errors: resource.errors.full_messages 
        }, status: :unprocessable_entity
      else
        respond_with(resource)
      end
    end
  end

  # PUT /users/password
  def update
    if request.format.json?
      email = params.dig(:user, :email)
      recovery_code = params.dig(:user, :recovery_code)
      password = params.dig(:user, :password)
      password_confirmation = params.dig(:user, :password_confirmation)
      
      user = User.find_by(email: email)
      
      if user.nil?
        return render json: { 
          error: 'Usuario no encontrado' 
        }, status: :not_found
      end
      
      # Verificar el código de recuperación
      unless user.recovery_code_valid?(recovery_code)
        return render json: { 
          error: 'Código inválido o expirado' 
        }, status: :unprocessable_entity
      end
      
      # Cambiar la contraseña
      if user.update(password: password, password_confirmation: password_confirmation)
        # Limpiar el código de recuperación
        user.clear_recovery_code
        
        return render json: { 
          message: 'Contraseña cambiada exitosamente' 
        }, status: :ok
      else
        return render json: { 
          error: user.errors.full_messages.join(', ') 
        }, status: :unprocessable_entity
      end
    end
    
    # Comportamiento original para HTML
    super
  end

  # 👇 Este método se ejecuta antes de renderizar la vista
  before_action :disable_layout_for_sidebar

  private

  def disable_layout_for_sidebar
    if request.headers["X-Requested-Sidebar"].present?
      self.class.layout false
    end
  end
end
