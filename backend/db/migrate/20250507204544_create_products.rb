class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :nombre
      t.string :descripcion
      t.decimal :precio
      t.integer :stock
      t.references :category_id, null: false, foreign_key: true
      t.references :supplier_id, null: false, foreign_key: true

      t.timestamps
    end
  end
end
