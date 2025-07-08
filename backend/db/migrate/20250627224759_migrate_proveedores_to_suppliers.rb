class MigrateProveedoresToSuppliers < ActiveRecord::Migration[7.1]
  def up
    # Ya no existe la tabla `proveedors`, así que esta migración queda vacía
  end

  def down
    # No hay cambios que revertir
  end
end
