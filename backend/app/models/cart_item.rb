# app/models/cart_item.rb
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  # Mapear quantity a la columna 'cantidad' (si existe) para compatibilidad con vistas existentes
  def quantity
    if has_attribute?(:cantidad)
      self.cantidad || 0
    else
      (self[:quantity] || 0)
    end
  end

  def quantity=(val)
    if has_attribute?(:cantidad)
      self.cantidad = val
    else
      self[:quantity] = val
    end
  end

  # Total por línea (unidad * cantidad)
  def total_price
    unit = product&.precio.to_f
    unit * quantity.to_i
  end
end
