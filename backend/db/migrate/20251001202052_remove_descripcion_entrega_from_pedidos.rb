class RemoveDescripcionEntregaFromPedidos < ActiveRecord::Migration[8.0]
  def change
    remove_column :pedidos, :descripcion_entrega, :string
  end
end
