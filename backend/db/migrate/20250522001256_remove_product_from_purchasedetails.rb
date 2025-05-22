class RemoveProductFromPurchasedetails < ActiveRecord::Migration[8.0]
  def change
    remove_reference :purchasedetails, :product
    remove_reference :purchasedetails, :buy, foreign_key: true
  end
end
