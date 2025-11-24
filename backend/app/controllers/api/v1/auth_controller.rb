class Api::V1::AuthController < ApplicationController
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

  private


  def login_params
    params.permit(:email, :password)
  end

  def register_params
    params.permit(:name, :email, :password)
  end
end
