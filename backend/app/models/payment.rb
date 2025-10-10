class Payment < ApplicationRecord
  belongs_to :cart, optional: true
  belongs_to :user, optional: true

  enum :status, { pending: 0, paid: 1, failed: 2, cancelled: 3 }

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :pay_method, presence: true
  validates :token, presence: true
  validates :account_info, presence: true


  def amount_display
    ApplicationController.helpers.number_to_currency(amount)
  end
end

