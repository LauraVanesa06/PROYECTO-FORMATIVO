class AddEstadoToPedidos < ActiveRecord::Migration[8.0]
  def change
    add_column :pedidos, :estado, :string
  end
end
