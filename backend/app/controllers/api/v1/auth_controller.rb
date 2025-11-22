class Api::V1::AuthController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!, only: [:login, :register]

  def login
    Rails.logger.info "Login params: #{params.inspect}"
    
    user = User.find_by(email: params[:email])
    if user&.valid_password?(params[:password])
      token = JsonWebToken.encode({ user_id: user.id })
      render json: {
        status: 'success',
        token: token,
        user: {
          id: user.id,
          email: user.email,
          role: user.role
        }
      }
    else
      render json: { 
        status: 'error',
        message: 'Invalid credentials' 
      }, status: :unauthorized
    end
  end

  def register
    user = User.new(register_params)
    
    if user.save
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
