class ContactarTecnicoMailer < ApplicationMailer
  default from: 'lvanesadelahoz@gmail.com'

  def reporte_error(support_request)
    @support_request = support_request

    mail(
      to: 'lvanesadelahoz@gmail.com', 
      subject: 'Nueva solicitud de ayuda',
      reply_to: @support_request.user_email  
    )
  end

  def confirm_user(support_request)
    @support_request = support_request

    mail(
      to: @support_request.user_email,
      subject: 'Confirmación de solicitud de ayuda'
    )
  end    
end


