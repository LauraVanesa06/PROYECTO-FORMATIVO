class RemoveProveedorIdFromProducts < ActiveRecord::Migration[8.0]
  def change
     if column_exists?(:products, :proveedor_id)
      remove_column :products, :proveedor_id
    end
  end
end
