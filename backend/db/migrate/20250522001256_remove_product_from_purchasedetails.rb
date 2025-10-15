class RemoveProductFromPurchasedetails < ActiveRecord::Migration[8.0]
  def change
    if column_exists?(:purchasedetails, :product_id)
      remove_reference :purchasedetails, :product
    end
    remove_reference :purchasedetails, :buy, foreign_key: true
  end
end
