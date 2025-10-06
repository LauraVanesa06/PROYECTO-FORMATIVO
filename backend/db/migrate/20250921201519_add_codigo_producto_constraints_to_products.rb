class AddCodigoProductoConstraintsToProducts < ActiveRecord::Migration[8.0]
  def change
    # Aseguramos que la columna exista (si no la tienes aún)
    unless column_exists?(:products, :codigo_producto)
      add_column :products, :codigo_producto, :string
    end

    reversible do |dir|
      dir.up do
        # Actualiza los productos con codigo_producto nulo usando SQL puro
        execute <<-SQL.squish
          UPDATE products
          SET codigo_producto = 'TEMP_' || id
          WHERE codigo_producto IS NULL
        SQL
      end
    end

    # Añadimos índice único solo si no existe
    add_index :products, :codigo_producto, unique: true, if_not_exists: true
    # Opcional: no permitir valores nulos
    change_column_null :products, :codigo_producto, false
  end
end
