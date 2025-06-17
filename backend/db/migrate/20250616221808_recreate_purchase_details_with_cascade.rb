class RecreatePurchaseDetailsWithCascade < ActiveRecord::Migration[8.0]
  def change
    rename_table :purchasedetails, :old_purchasedetails

    create_table :purchasedetails do |t|
      t.references :buy, null: false, foreign_key: { on_delete: :cascade }
      t.references :product, null: false, foreign_key: { on_delete: :cascade }
      t.integer :quantity
      t.decimal :price

      t.timestamps
    end

    drop_table :old_purchasedetails
    
  end
end
