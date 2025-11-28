class MakeUserIdNullableInBuys < ActiveRecord::Migration[8.0]
  def change
    change_column_null :buys, :user_id, true
  end
end
