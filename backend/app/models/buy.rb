class Buy < ApplicationRecord
  belongs_to :user
  has_many :purchasedetails, dependent: :destroy
  has_many :buy_products, dependent: :destroy
  belongs_to :payment, optional: true
  has_many :products, through: :purchasedetails



  validates :fecha, :tipo, :metodo_pago, presence: true

end
