class AddproductoidtoPurchasedetails < ActiveRecord::Migration[8.0]
  def change
    add_reference :purchasedetails, :product, null: false, foreign_key: true
  end
end
