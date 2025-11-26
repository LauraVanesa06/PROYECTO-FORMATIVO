class Api::V1::ApiController < ActionController::API
  include ActionController::RequestForgeryProtection
  
  protect_from_forgery with: :null_session
    before_action :authenticate_user_from_token!
      attr_reader :current_user


  private

  def authenticate_user_from_token!
    token = request.headers['Authorization']&.split(' ')&.last
    return render json: { error: "Token requerido" }, status: :unauthorized unless token

    begin
      payload = JsonWebToken.decode(token)
      @current_user = User.find_by(id: payload['user_id'])
      return render json: { error: 'Usuario no encontrado' }, status: :unauthorized unless @current_user
    rescue JWT::DecodeError => e
      render json: { error: 'Token inválido' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
