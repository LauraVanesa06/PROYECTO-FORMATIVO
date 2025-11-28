class AddClientInfoToBuys < ActiveRecord::Migration[8.0]
  def change
    add_column :buys, :client_name, :string
    add_column :buys, :client_email, :string
  end
end
