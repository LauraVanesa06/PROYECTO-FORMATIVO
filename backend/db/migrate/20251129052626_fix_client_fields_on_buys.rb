class FixClientFieldsOnBuys < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:buys, :client_name)
      add_column :buys, :client_name, :string
    end

    unless column_exists?(:buys, :client_email)
      add_column :buys, :client_email, :string
    end

  end
end
