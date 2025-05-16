class AddCategoryIdToProduct < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :category, null: false, foreign_key: true
  end
end
