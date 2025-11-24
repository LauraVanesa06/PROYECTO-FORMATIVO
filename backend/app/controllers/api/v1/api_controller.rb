class Api::V1::ApiController < ActionController::API
  before_action :authenticate_user_from_token!

  private

  def authenticate_user_from_token!
    token = request.headers['Authorization']&.split(' ')&.last
    return unless token

    begin
      payload = JsonWebToken.decode(token)
      @current_user = User.find_by(id: payload['user_id'])
    rescue JWT::DecodeError
      render json: { error: 'Token inválido' }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
