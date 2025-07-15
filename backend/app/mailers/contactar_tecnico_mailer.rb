class ContactarTecnicoMailer < ApplicationMailer
  default from: 'lvanesadelahoz@gmail.com'

  def reporte_error(nombre, usuario, descripcion, tecnico_email)
    @nombre = nombre
    @usuario = usuario
    @descripcion = descripcion

    mail(to: tecnico_email, subject: 'Nuevo reporte técnico desde el sistema')
  end
end


