class AddCantidadToPedidoProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :pedido_products, :cantidad, :integer
  end
end
