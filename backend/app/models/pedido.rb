
class Pedido < ApplicationRecord
  belongs_to :supplier
  has_many :pedido_products
  has_many :products, through: :pedido_products
end
