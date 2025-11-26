class Payment < ApplicationRecord
  belongs_to :cart 
  belongs_to :user
  has_one :buy, dependent: :nullify

  after_update :create_buy_if_paid

  private

  def create_buy_if_paid
    return unless saved_change_to_status? && status == "APPROVED"
    return if Buy.exists?(payment_id: id)

    ActiveRecord::Base.transaction do
      total_compra = cart.cart_items.sum { |i| (i.product&.precio || 0) * (i.cantidad || 1) }

      buy = Buy.create!(
        user_id: user.id,
        fecha: Time.current,
        tipo: "Online",
        metodo_pago: "Online",
        total: total_compra,
        payment_id: id
      )

      cart.cart_items.each do |item|
        Purchasedetail.create(
          buy_id: buy.id,
          product_id: item.product_id,
          cantidad: item.cantidad || 1,
          preciounidad: item.product&.precio&.to_d || 0
        )
      end

      cart.cart_items.destroy_all
    end
  end

end
