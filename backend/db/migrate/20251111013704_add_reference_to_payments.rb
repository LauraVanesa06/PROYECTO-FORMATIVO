class AddReferenceToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :reference, :string
    add_index :payments, :reference
  end
end
