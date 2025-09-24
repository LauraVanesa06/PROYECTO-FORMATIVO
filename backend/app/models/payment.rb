class Payment < ApplicationRecord
  belongs_to :cart
  enum :status, { pending: 0, approved: 1, declined: 2 }

  validates :amount, presence: true
  validates :pay_method, presence: true
validates :account_info, presence: true

  after_initialize :set_default_status, if: :new_record?

  private

  def set_default_status
    self.status ||= :pending
  end
end

