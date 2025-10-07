class PedidoMailer < ApplicationMailer
  default from: 'ferreteriasoporte3@gmail.com'

  def notificar_proveedor(pedido)
    @pedido = pedido
    @proveedor = pedido.supplier
    mail(to: @proveedor.correo, subject: "Nuevo pedido ##{@pedido.id} para #{@proveedor.nombre}")
  end
end
