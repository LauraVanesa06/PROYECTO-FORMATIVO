# app/models/cart_item.rb
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  # Alias para que quantity funcione igual que cantidad
  def quantity
    cantidad
  end

  def quantity=(value)
    self.cantidad = value
  end
end
