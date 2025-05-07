class Product < ApplicationRecord
  belongs_to :category_id
  belongs_to :supplier_id
end
