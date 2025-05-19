class CreatePurchasedetails < ActiveRecord::Migration[8.0]
  def change
    create_table :purchasedetails do |t|
      t.references :buy, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true
      t.integer :cantidad
      t.decimal :preciounidad

      t.timestamps
    end
  end
end
