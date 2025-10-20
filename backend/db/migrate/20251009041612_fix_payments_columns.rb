class FixPaymentsColumns < ActiveRecord::Migration[8.0]
  def up
    # Cambiar columnas existentes
    change_column :payments, :amount, :decimal, precision: 12, scale: 2, null: false rescue nil
    change_column :payments, :status, :integer, null: false, default: 0 rescue nil
    change_column_null :payments, :pay_method, false rescue nil
    change_column_null :payments, :cart_id, false rescue nil
    change_column :payments, :token, :string, null: false rescue nil

    # Agregar columnas solo si no existen
    add_column :payments, :currency, :string, null: false, default: "COP" unless column_exists?(:payments, :currency)
    add_column :payments, :wompi_id, :string, null: false unless column_exists?(:payments, :wompi_id)
    add_column :payments, :raw_response, :jsonb, null: false, default: {} unless column_exists?(:payments, :raw_response)
    add_column :payments, :account_info, :string, null: false unless column_exists?(:payments, :account_info)

    # Agregar relación solo si no existe
    add_reference :payments, :user, null: false, foreign_key: true unless column_exists?(:payments, :user_id)
  end

  def down
    remove_column :payments, :currency if column_exists?(:payments, :currency)
    remove_column :payments, :wompi_id if column_exists?(:payments, :wompi_id)
    remove_column :payments, :raw_response if column_exists?(:payments, :raw_response)
    remove_column :payments, :account_info if column_exists?(:payments, :account_info)
    remove_reference :payments, :user, foreign_key: true if column_exists?(:payments, :user_id)

    change_column_null :payments, :cart_id, true rescue nil
    change_column_null :payments, :pay_method, true rescue nil
    change_column :payments, :status, :integer, default: nil rescue nil
    change_column :payments, :amount, :decimal rescue nil
    change_column :payments, :token, :string rescue nil
  end
end
