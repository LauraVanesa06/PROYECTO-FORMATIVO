module Api
  module V1
    class PasswordsController < ApplicationController
      skip_before_action :verify_authenticity_token
      
      # POST /api/v1/auth/forgot-password
      def forgot_password
        email = params[:email]

        if email.blank?
          return render json: { 
            error: 'El correo electrónico es requerido' 
          }, status: :unprocessable_entity
        end

        user = User.find_by(email: email)

        if user.nil?
          return render json: { 
            error: 'El correo electrónico no se encuentra registrado' 
          }, status: :not_found
        end

        # Generar código de verificación (6 dígitos)
        verification_code = rand(100000..999999).to_s
        
        # Guardar el código en el usuario (puedes crear un campo reset_password_code)
        user.update(
          reset_password_token: verification_code,
          reset_password_sent_at: Time.current
        )

        # Enviar email con el código
        # UserMailer.password_reset(user, verification_code).deliver_later

        render json: { 
          message: 'Código de verificación enviado a tu correo electrónico',
          email: user.email
        }, status: :ok
      end

      # POST /api/v1/auth/verify-reset-code
      def verify_reset_code
        email = params[:email]
        code = params[:code]

        user = User.find_by(email: email)

        if user.nil? || user.reset_password_token != code
          return render json: { 
            error: 'Código de verificación inválido' 
          }, status: :unprocessable_entity
        end

        # Verificar que el código no haya expirado (10 minutos)
        if user.reset_password_sent_at < 10.minutes.ago
          return render json: { 
            error: 'El código de verificación ha expirado' 
          }, status: :unprocessable_entity
        end

        render json: { 
          message: 'Código verificado correctamente',
          token: user.reset_password_token
        }, status: :ok
      end

      # POST /api/v1/auth/reset-password
      def reset_password
        email = params[:email]
        code = params[:code]
        new_password = params[:password]
        password_confirmation = params[:password_confirmation]

        user = User.find_by(email: email)

        if user.nil? || user.reset_password_token != code
          return render json: { 
            error: 'Código de verificación inválido' 
          }, status: :unprocessable_entity
        end

        if user.reset_password_sent_at < 10.minutes.ago
          return render json: { 
            error: 'El código de verificación ha expirado' 
          }, status: :unprocessable_entity
        end

        if new_password != password_confirmation
          return render json: { 
            error: 'Las contraseñas no coinciden' 
          }, status: :unprocessable_entity
        end

        if user.update(password: new_password, password_confirmation: password_confirmation)
          # Limpiar el token
          user.update(reset_password_token: nil, reset_password_sent_at: nil)
          
          render json: { 
            message: 'Contraseña actualizada correctamente' 
          }, status: :ok
        else
          render json: { 
            error: user.errors.full_messages.join(', ') 
          }, status: :unprocessable_entity
        end
      end
    end
  end
end
