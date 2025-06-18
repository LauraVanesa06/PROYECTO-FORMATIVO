class UpdatePurchasedetailsStructure < ActiveRecord::Migration[8.0]
  def change
    remove_column :purchasedetails, :quantity, :integer
    remove_column :purchasedetails, :price, :decimal

    add_column :purchasedetails, :cantidad, :integer
    add_column :purchasedetails, :preciounidad, :decimal
  end
end
