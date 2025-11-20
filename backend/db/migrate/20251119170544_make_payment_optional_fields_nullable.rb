class MakePaymentOptionalFieldsNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :payments, :wompi_id, true
    change_column_null :payments, :pay_method, true
    change_column_null :payments, :token, true
    change_column_null :payments, :account_info, true
  end
end
