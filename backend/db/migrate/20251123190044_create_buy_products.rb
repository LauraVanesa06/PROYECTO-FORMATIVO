class CreateBuyProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :buy_products do |t|
      t.references :buy, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :cantidad
      t.decimal :precio_unitario

      t.timestamps
    end
  end
end
