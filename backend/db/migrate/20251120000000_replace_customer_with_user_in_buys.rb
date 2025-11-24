class ReplaceCustomerWithUserInBuys < ActiveRecord::Migration[8.0]
  def up
    # Si la columna customer_id existe, removerla
    if column_exists?(:buys, :customer_id)
      #begin
        remove_foreign_key :buys, :customers rescue nil
     # rescue ActiveRecord::StatementInvalid
        # La FK podría no existir
      #end
      remove_column :buys, :customer_id
    end

    # Si la columna user_id no existe, agregarla
    unless column_exists?(:buys, :user_id)
      add_reference :buys, :user, null: true, foreign_key: true
    end

      encrypted_pass = "$2a$12$KIX9wQOH4cVwqDAVBBusduInxjeRGna43EIBgzHuLlHotE5T7BC5m"

      execute <<-SQL
        INSERT INTO users (name, email, encrypted_password, role, created_at, updated_at)
        VALUES ('Default User', 'user_null@gmail.com', '#{encrypted_pass}', 'user', NOW(), NOW());
      SQL

      default_user_id = select_value("SELECT id FROM users ORDER BY id DESC LIMIT 1")

      execute <<-SQL
        UPDATE buys SET user_id = #{default_user_id} WHERE user_id IS NULL;
      SQL

    change_column_null :buys, :user_id, false
  end

  def down
    
    change_column_null :buys, :user_id, true rescue nil

    if column_exists?(:buys, :user_id)
      change_column_null :buys, :user_id, true rescue nil
      remove_reference :buys, :user, foreign_key: true
    end

    unless column_exists?(:buys, :customer_id)
      add_reference :buys, :customer, foreign_key: true, null: true
    end
  end
end
