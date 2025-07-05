class MigrateProveedoresToSuppliers < ActiveRecord::Migration[8.0]
  def up
    Proveedor.all.each do |p|
      Supplier.create!(
        nombre: p.nombre,
        contacto: p.telefono
      )
    end
  end
end
