class RemoveDefaultFromCodigoProducto < ActiveRecord::Migration[8.0]
  def change
    change_column_default :products, :codigo_producto, from: "P0001", to: nil
  end
end
