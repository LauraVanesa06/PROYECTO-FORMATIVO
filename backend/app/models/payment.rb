class Payment < ApplicationRecord
  belongs_to :cart, optional: true
  belongs_to :user, optional: true

  enum :status, { pending: 0, paid: 1, failed: 2, cancelled: 3 }

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :pay_method, presence: true
  validates :token, presence: true
  validates :account_info, presence: true

  after_update :register_buy_if_paid



  def amount_display
    ApplicationController.helpers.number_to_currency(amount)
  end

  after_update :generate_buy_if_paid

private

def generate_buy_if_paid
  return unless saved_change_to_status? && status == "paid"

  # Evitar crear la compra más de una vez
  return if Buy.exists?(customer_id: user_id, fecha: Date.today)

  # Crear la compra
  buy = Buy.create!(
    customer_id: user_id,
    fecha: Date.today
  )

  # Crear los detalles con base en el carrito
  if cart
    cart.cart_items.includes(:product).each do |item|
      Purchasedetail.create!(
        buy: buy,
        product: item.product,
        cantidad: item.quantity,
        preciounidad: item.product.precio
      )
    end
  end

  # Vaciar el carrito tras la compra
  cart.cart_items.destroy_all
end
end 
