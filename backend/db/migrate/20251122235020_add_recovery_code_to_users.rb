class AddRecoveryCodeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :recovery_code, :string
    add_column :users, :recovery_code_sent_at, :datetime
  end
end
