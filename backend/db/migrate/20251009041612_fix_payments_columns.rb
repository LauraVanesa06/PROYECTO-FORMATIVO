class FixPaymentsColumns < ActiveRecord::Migration[8.0]
  def up
    change_column :payments, :amount, :decimal, precision: 12, scale: 2, null: false
    add_column :payments, :currency, :string, null: false, default: "COP"
    change_column :payments, :status, :integer, null: false, default: 0
    add_column :payments, :wompi_id, :string, null: false
    change_column_null :payments, :pay_method, false
    add_reference :payments, :user, null: false, foreign_key: true
    change_column_null :payments, :cart_id, false
    add_column :payments, :raw_response, :jsonb, null: false, default: {}
    change_column :payments, :token, :string, null: false
    add_column :payments, :account_info, :string, null: false
  end

  def down
    remove_column :payments, :currency
    remove_column :payments, :wompi_id
    remove_column :payments, :raw_response
    remove_column :payments, :account_info
    remove_reference :payments, :user, foreign_key: true


    change_column_null :payments, :cart_id, true
    change_column_null :payments, :pay_method, true
    change_column :payments, :status, :integer, default: nil
    change_column :payments, :amount, :decimal
    change_column :payments, :token, :string
  end
end
