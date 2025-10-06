class PedidoProduct < ApplicationRecord
  belongs_to :product
  belongs_to :pedido
end
