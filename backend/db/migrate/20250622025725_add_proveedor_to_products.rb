class AddProveedorToProducts < ActiveRecord::Migration[8.0]
  def change
add_reference :products, :proveedor, null: true, foreign_key: true
  end
end
