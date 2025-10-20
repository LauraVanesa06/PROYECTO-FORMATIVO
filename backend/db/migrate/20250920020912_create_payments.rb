class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false, default: "COP"
      t.integer :status, null: false, default: 0
      t.string :wompi_id, null: false
      t.string :pay_method, null: false
      t.references :user, foreign_key: true, null: false
      t.references :cart, foreign_key: true, null: false
      t.jsonb :raw_response, default: {}, null: false
      t.string :token
      t.string :account_info, null: false 

      t.timestamps
    end
  add_index :payments, :wompi_id, unique: true
  end
end
