class CreateSupportRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :support_requests do |t|
      t.string :user_name
      t.string :user_email
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
