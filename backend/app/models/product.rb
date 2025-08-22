class Product < ApplicationRecord
  # Relacion favoritos
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user

  # Relacion carrito
  has_many :cart_items

  belongs_to :category
  belongs_to :supplier
  has_many :purchasedetails, dependent: :destroy
  validates :nombre, uniqueness: { scope: :supplier_id }
  validates :precio, numericality: { greater_than_or_equal_to: 0 }, presence: true
  
  has_one_attached :imagen, dependent: :purge
end
