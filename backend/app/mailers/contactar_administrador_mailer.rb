class ContactarAdministradorMailer < ApplicationMailer
     default from: 'lvanesadelahoz@gmail.com'

  def reporte_duda(user_support)
    @user_support = user_support

    mail(
      to: 'lvanesadelahoz@gmail.com', 
      subject: 'Nueva solicitud de ayuda',
      reply_to: @user_support.user_email  
    )
  end

  def confirmar_user(user_support)
    @user_support = user_support

    mail(
      to: @user_support.user_email,
      subject: 'Confirmación de solicitud de duda'
    )
  end
end
