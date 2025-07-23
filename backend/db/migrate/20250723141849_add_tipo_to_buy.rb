class AddTipoToBuy < ActiveRecord::Migration[8.0]
  def change
    add_column :buys, :tipo, :string
  end
end
