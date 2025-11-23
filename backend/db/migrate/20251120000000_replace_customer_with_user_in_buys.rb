class ReplaceCustomerWithUserInBuys < ActiveRecord::Migration[8.0]
  def up
    # Si la columna customer_id existe, removerla
    if column_exists?(:buys, :customer_id)
      begin
        remove_foreign_key :buys, :customers
      rescue ActiveRecord::StatementInvalid
        # La FK podría no existir
      end
      remove_column :buys, :customer_id
    end

    # Si la columna user_id no existe, agregarla
    unless column_exists?(:buys, :user_id)
      add_reference :buys, :user, null: true, foreign_key: true
    end

    default_user = User.first || User.create!(
      email: "user_null@gmail.com",
      password: "123456"
    )

    Buy.where(user_id: nil).update_all(user_id: default_user.id)
    
    change_column_null :buys, :user_id, false
  end

  def down
    if column_exists?(:buys, :user_id)
      change_column_null :buys, :user_id, true rescue nil
      remove_reference :buys, :user, foreign_key: true
    end

    unless column_exists?(:buys, :customer_id)
      add_reference :buys, :customer, foreign_key: true, null: true
    end
  end
end
