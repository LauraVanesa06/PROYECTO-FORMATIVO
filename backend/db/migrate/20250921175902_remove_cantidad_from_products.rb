class RemoveCantidadFromProducts < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :cantidad, :integer
  end
end
