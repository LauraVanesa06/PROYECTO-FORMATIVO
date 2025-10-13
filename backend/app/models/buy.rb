class Buy < ApplicationRecord
  belongs_to :customer
  has_many :purchasedetails
  belongs_to :payment, optional: true
end
