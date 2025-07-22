class ContactarTecnicoMailer < ApplicationMailer
  default from: 'lvanesadelahoz@gmail.com'

  #def reporte_error(nombre, usuario, descripcion, tecnico_email)
   # @nombre = nombre
 #   @usuario = usuario
    #@descripcion = descripcion

def notify_technician(support_request)
    @support_request = support_request

    mail(to: tecnico_email, subject: 'Nuevo reporte técnico desde el sistema')
  end
end


