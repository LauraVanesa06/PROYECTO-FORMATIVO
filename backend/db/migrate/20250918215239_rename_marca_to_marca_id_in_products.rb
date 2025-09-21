class RenameMarcaToMarcaIdInProducts < ActiveRecord::Migration[8.0]
  def change
    rename_column :products, :marca, :marca_id
    change_column :products, :marca_id, :integer
  end
end
