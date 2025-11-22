class PasswordResetMailer < ApplicationMailer
  default from: 'ferreteriasoporte3@gmail.com'

  def reset_code_email(user, code)
    @user = user
    @code = code
    mail(to: @user.email, subject: 'Código de recuperación de contraseña')
  end
end
