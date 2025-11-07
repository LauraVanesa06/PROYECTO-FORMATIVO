# app/lib/json_web_token.rb
require 'jwt'

class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base.to_s

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::ExpiredSignature
    raise JWT::DecodeError, 'Token expirado'
  rescue JWT::DecodeError
    raise JWT::DecodeError, 'Token inválido'
  end
end
