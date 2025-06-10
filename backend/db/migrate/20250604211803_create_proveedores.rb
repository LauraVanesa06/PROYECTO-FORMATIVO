class CreateProveedores < ActiveRecord::Migration[8.0]
  def change
    create_table :proveedores do |t|
      t.string :nombre
      t.string :tipoProducto
      t.string :direccion
      t.integer :telefono
      t.string :correo

      t.timestamps
    end
  end
end
