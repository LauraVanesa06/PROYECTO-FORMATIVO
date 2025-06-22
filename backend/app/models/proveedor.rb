class Proveedor < ApplicationRecord
      has_many :productos, class_name: "Product", foreign_key: "proveedor_id", dependent: :destroy
end
