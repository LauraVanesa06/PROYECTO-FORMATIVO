class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :cart, null: false, foreign_key: true
      t.string :transaction_id
      t.integer :status, default: 0
      t.decimal :amount, precision:12, scale: 2
      t.string :pay_method 
      t.string :token

      t.timestamps
    end
  end
end
