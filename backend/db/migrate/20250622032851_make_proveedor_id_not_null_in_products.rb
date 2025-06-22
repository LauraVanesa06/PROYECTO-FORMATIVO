class MakeProveedorIdNotNullInProducts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :products, :proveedor_id, false
  end
end
