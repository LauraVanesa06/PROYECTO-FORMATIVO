class Payment < ApplicationRecord
  belongs_to :cart   # singular
  enum status: { pending: 0, approved: 1, declined: 2 }

  validates :amount, presence: true
  validates :pay_method, presence: true
end