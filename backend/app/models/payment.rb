class Payment < ApplicationRecord
  belongs_to :cart, optional: true
  belongs_to :user, optional: true
  has_one :buy

  enum :status, { pending: 0, paid: 1, failed: 2, cancelled: 3 }

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, :pay_method, :token, :account_info, presence: true

  after_update :generate_buy_if_paid

  def amount_display
    ApplicationController.helpers.number_to_currency(amount)
  end

  private

  def generate_buy_if_paid
    return unless saved_change_to_status? && status == "paid"
    return if Buy.exists?(payment_id: id)

    begin
      ActiveRecord::Base.transaction do
        buy = Buy.create!(
          customer_id: user_id,
          fecha: Date.today,
          payment_id: id,
          total: amount
        )

        if cart
          cart.cart_items.includes(:product).each do |item|
            Purchasedetail.create!(
              buy: buy,
              product: item.product,
              cantidad: item.quantity,
              preciounidad: item.product.precio
            )
          end

          # Vaciar el carrito tras la compra
          cart.cart_items.destroy_all
        end
      end
    rescue => e
      Rails.logger.error("[Payments] Error creando Buy desde Payment #{id}: #{e.full_message}")
    end
  end
end
