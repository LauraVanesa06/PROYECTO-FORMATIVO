class AddFieldsToProductPedidoSupplier < ActiveRecord::Migration[8.0]
  def change
    change_table :products do |t|
      t.string :codigo_producto
      t.integer :cantidad
      t.string :modelo
      t.string :marca
    end
    add_index :products, :codigo_producto, unique: true

    change_table :pedidos do |t|
      t.integer :stock
      t.string :proveedor
    end

    change_table :suppliers do |t|
      t.string :codigo_proveedor
    end
    add_index :suppliers, :codigo_proveedor, unique: true

  end
end
