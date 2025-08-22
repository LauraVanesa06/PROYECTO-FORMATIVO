class AddDisponibleToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :disponible, :boolean
  end
end
