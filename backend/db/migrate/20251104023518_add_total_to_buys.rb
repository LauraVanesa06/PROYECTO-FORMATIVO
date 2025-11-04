class AddTotalToBuys < ActiveRecord::Migration[8.0]
  def change
    add_column :buys, :total, :decimal, precision: 12, scale: 2
  end
end
