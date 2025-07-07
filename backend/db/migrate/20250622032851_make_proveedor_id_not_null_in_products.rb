class MakeProveedorIdNotNullInProducts < ActiveRecord::Migration[7.1]
  def up
    # Creamos un proveedor por defecto si no existe
    proveedor = Supplier.first || Supplier.create!(nombre: "Proveedor por defecto")

    # Asignamos ese proveedor a todos los productos sin proveedor
    Product.where(proveedor_id: nil).update_all(proveedor_id: proveedor.id)

    # Ahora sí hacemos la columna obligatoria
    change_column_null :products, :proveedor_id, false
  end

  def down
    # Permitir que vuelva a ser null si se hace rollback
    change_column_null :products, :proveedor_id, true
  end
end
