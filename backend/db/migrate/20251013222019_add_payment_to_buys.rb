class AddPaymentToBuys < ActiveRecord::Migration[8.0]
  def change
    add_reference :buys, :payment, null: true, foreign_key: true
  end
end
