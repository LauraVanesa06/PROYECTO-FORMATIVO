class RemoveSupplierFromPurchasedetails < ActiveRecord::Migration[8.0]
  def change
    remove_reference :purchasedetails, :supplier
  end
end
