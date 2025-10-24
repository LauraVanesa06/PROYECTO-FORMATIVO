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
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode({ user_id: user.id })
      render json: {
        status: 'success',
        token: token,
        user: {
          id: user.id,
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

  def user_params
    params.permit(:email, :password)
  end
end
