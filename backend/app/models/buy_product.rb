class BuyProduct < ApplicationRecord
  belongs_to :buy
  belongs_to :product
end
