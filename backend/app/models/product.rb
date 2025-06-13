class Product < ApplicationRecord

  belongs_to :category
  belongs_to :supplier
  has_many :purchasedetail

  has_one_attached :imagen
end
