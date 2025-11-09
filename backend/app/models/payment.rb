class Payment < ApplicationRecord
  belongs_to :cart 
  belongs_to :user
  has_one :buy, dependent: :nullify

  after_update :create_buy_if_paid

  private

  def create_buy_if_paid
    return unless saved_change_to_status? && status == "APPROVED"
    return if Buy.exists?(payment_id: id)

    Buy.create!(
      customer: user.customer, # si tu usuario tiene cliente asociado
      payment: self,
      fecha: Time.current,
      tipo: "Venta",
      metodo_pago: "Wompi"
    )
  end

end
