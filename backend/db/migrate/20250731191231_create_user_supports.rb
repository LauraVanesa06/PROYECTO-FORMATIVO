class CreateUserSupports < ActiveRecord::Migration[8.0]
  def change
    create_table :user_supports do |t|
      t.string :user_name
      t.string :user_apellido
      t.string :user_email
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end
