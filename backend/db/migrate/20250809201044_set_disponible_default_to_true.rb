class SetDisponibleDefaultToTrue < ActiveRecord::Migration[8.0]
  def change
    change_column_default :products, :disponible, from: false, to: true
  end
end
