class Customer < ApplicationRecord
  has_many :buys
  has_many :purchasedetails, through: :buys 
end
