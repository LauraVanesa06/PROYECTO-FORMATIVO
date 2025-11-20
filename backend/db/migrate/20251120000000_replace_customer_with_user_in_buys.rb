class ReplaceCustomerWithUserInBuys < ActiveRecord::Migration[8.0]
  def change
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
      add_reference :buys, :user, null: false, foreign_key: true
    end
  end
end
