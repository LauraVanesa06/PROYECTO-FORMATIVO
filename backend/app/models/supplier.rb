class Supplier < ApplicationRecord
  has_many :products, class_name: "Product", foreign_key: "supplier_id", dependent: :destroy
  accepts_nested_attributes_for :products
  has_many :pedidos

  before_create :generate_code
  validates :codigo_proveedor, uniqueness: true

  private

  def generate_code
    loop do
      initials = nombre.split.map { |word| word[0] }.join.upcase
      last_supplier = Supplier.where("codigo_proveedor LIKE ?", "#{initials}%").order(:codigo_proveedor).last
      last_number = last_supplier.present? ? last_supplier.codigo_proveedor.gsub(initials, "").to_i : 0
      next_number = last_number + 1
      candidate = "PR-#{initials}#{next_number.to_s.rjust(3, '0')}"

      unless Supplier.exists?(codigo_proveedor: candidate)
        self.codigo_proveedor = candidate
        break
      end
    end
  end
end
