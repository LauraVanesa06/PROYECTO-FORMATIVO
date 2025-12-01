class AddImagenUrlToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :imagen_url, :string
  end
end
