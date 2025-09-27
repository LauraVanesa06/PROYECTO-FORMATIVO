class CreatePedidos < ActiveRecord::Migration[8.0]
  def change
    create_table :pedidos do |t|
      t.datetime :fecha
      t.json :productos
      t.string :descripcion_entrega
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end
