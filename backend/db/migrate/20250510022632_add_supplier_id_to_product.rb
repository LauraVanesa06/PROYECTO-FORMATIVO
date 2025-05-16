class AddSupplierIdToProduct < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :supplier, null: false, foreign_key: true
  end
end
