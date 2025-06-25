class AddDocumentoTocustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :documento, :integer
  end
end
