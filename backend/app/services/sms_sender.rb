# frozen_string_literal: true

require 'twilio-ruby'

class SmsSender
  # Configura tus credenciales de Twilio aquí o usa variables de entorno
  ACCOUNT_SID = ENV['TWILIO_ACCOUNT_SID'] || 'TU_ACCOUNT_SID'
  AUTH_TOKEN = ENV['TWILIO_AUTH_TOKEN'] || 'TU_AUTH_TOKEN'
  FROM_NUMBER = ENV['TWILIO_PHONE_NUMBER'] || '+1234567890'

  def self.send_sms(to:, body:)
    client = Twilio::REST::Client.new(ACCOUNT_SID, AUTH_TOKEN)
    client.messages.create(
      from: FROM_NUMBER,
      to: to,
      body: body
    )
  end
end
