class Supplier < ApplicationRecord
        has_many :products, class_name: "Product", foreign_key: "supplier_id", dependent: :destroy

end
