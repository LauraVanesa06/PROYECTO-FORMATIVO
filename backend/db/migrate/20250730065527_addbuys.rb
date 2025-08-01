class Addbuys < ActiveRecord::Migration[8.0]
  def change
    add_column :buys, :metodo_pago, :string
  end
end
