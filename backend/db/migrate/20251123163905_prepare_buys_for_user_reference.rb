class PrepareBuysForUserReference < ActiveRecord::Migration[8.0]
  def up
    
    unless column_exists?(:buys, :user_id)
      add_reference :buys, :user, foreign_key: true, null: true
    end

    
    default_user = User.first || User.create!(
      email: "user@example.com",
      password: "password123"
    )

    
    Buy.where(user_id: nil).update_all(user_id: default_user.id)
  end

  def down
  
    if column_exists?(:buys, :user_id)
      remove_reference :buys, :user, foreign_key: true
    end    
  end
end
