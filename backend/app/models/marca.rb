class Marca < ApplicationRecord
  has_many :products

  def to_s
    nombre
  end
end
