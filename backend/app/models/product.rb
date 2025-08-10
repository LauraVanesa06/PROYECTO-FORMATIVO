class Product < ApplicationRecord
  belongs_to :category
  belongs_to :supplier
  has_many :cart_items
  has_many :purchasedetails, dependent: :destroy
validates :nombre, uniqueness: { scope: :supplier_id }


  has_one_attached :imagen, dependent: :purge
end
