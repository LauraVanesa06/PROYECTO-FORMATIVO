class PedidoMailer < ApplicationMailer
  default from: 'no-reply@ferremateriales.com'

  def notificar_proveedor(pedido)
    @pedido = pedido
    @proveedor = pedido.supplier
    mail(to: @proveedor.correo, subject: "Nuevo pedido ##{@pedido.id} para #{@proveedor.nombre}")
  end
end
