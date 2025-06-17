class Product < ApplicationRecord

  belongs_to :category
  belongs_to :supplier
  has_many :purchasedetail, dependent: :destroy

  has_one_attached :imagen, dependent: :purge
end
