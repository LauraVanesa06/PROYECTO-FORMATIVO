class AddCountersToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :purchases_count, :integer, default: 0
    add_column :products, :buyers_count, :integer, default: 0
  end
end
