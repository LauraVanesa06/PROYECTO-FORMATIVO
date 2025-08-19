class AddUserIdToCarts < ActiveRecord::Migration[8.0]
  def change
    add_reference :carts, :user, null: true, foreign_key: true
  end
end
