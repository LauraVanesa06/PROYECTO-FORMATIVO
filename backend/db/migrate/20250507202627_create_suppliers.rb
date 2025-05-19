class CreateSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :suppliers do |t|
      t.string :nombre
      t.string :contacto

      t.timestamps
    end
  end
end
