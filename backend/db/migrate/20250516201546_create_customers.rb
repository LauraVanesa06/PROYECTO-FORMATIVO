class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :nombre
      t.string :telefono

      t.timestamps
    end
  end
end
