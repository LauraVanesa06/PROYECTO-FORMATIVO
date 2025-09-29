class AddCorreoToSuppliers < ActiveRecord::Migration[8.0]
  def change
    add_column :suppliers, :correo, :string
  end
end
