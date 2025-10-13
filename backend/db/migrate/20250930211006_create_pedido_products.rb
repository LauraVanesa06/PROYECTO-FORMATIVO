class CreatePedidoProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :pedido_products do |t|
      t.references :product, null: false, foreign_key: true
      t.references :pedido, null: false, foreign_key: true

      t.timestamps
    end
  end
end
