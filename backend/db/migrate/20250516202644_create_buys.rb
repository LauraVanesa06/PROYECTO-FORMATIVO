class CreateBuys < ActiveRecord::Migration[8.0]
  def change
    create_table :buys do |t|
      t.references :customer, null: false, foreign_key: true
      t.datetime :fecha

      t.timestamps
    end
  end
end
