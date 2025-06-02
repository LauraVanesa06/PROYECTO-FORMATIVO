class Buy < ApplicationRecord
  belongs_to :customer
  has_many :purchasedetails
end
