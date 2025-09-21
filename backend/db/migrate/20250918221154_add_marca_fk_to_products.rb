class AddMarcaFkToProducts < ActiveRecord::Migration[8.0]
  def change
    add_foreign_key :products, :marcas, column: :marca_id
  end
end
