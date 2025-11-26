class AddRecoveryCodeToUsers < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:users, :recovery_code)
      add_column :users, :recovery_code, :string
    end
    
    unless column_exists?(:users, :recovery_code_sent_at)
      add_column :users, :recovery_code_sent_at, :datetime
    end
  end
end
