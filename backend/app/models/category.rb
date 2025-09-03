class Category < ApplicationRecord
  has_many :products
  has_one_attached :imagen   # 👈 logo/imagen de la categoría
end
