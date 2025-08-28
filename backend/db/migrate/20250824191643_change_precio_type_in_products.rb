class ChangePrecioTypeInProducts < ActiveRecord::Migration[8.0]
  def change
    change_column :products, :precio, :decimal, precision: 12, scale: 2
  end
end
