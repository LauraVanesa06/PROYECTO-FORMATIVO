class Supplier < ApplicationRecord
  has_many :products, class_name: "Product", foreign_key: "supplier_id", dependent: :destroy
  accepts_nested_attributes_for :products
  has_many :pedidos

  validates :correo, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "no es un correo válido" }
  validates :contacto, presence: true, format: { with: /\A\d{7,15}\z/, message: "solo puede contener entre 7 y 15 dígitos numéricos" }
  before_validation :normalize_codigo_proveedor
  validates :codigo_proveedor, presence: true, format: { with: /\A[A-Z0-9]+\z/, message: "solo puede contener letras mayúsculas y números" }

  private

  def normalize_codigo_proveedor
    self.codigo_proveedor = codigo_proveedor.to_s.upcase.gsub(/[^A-Z0-9]/, '') if codigo_proveedor.present?
  end

end
