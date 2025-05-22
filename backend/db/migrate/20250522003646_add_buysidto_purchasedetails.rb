class AddBuysidtoPurchasedetails < ActiveRecord::Migration[8.0]
  def change
    add_reference :purchasedetails, :buy, null: false, foreign_key: true
  end
end
