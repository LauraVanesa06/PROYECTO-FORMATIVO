class RemoveProveedorIdFromProducts < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :proveedor_id, :integer
  end
end
