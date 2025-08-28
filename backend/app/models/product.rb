class Product < ApplicationRecord
  # Relacion favoritos
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user

  # Relacion carrito
  has_many :cart_items

  belongs_to :category
  belongs_to :supplier
  has_many :purchasedetails, dependent: :destroy
  validates :nombre, uniqueness: { scope: :supplier_id }
  validates :precio, numericality: { greater_than_or_equal_to: 0 }, presence: true
  
  has_many_attached :images, dependent: :purge
  validate :acceptable_images

  
  def precio_cop
    ApplicationController.helpers.number_to_currency(precio, unit: "", separator: ",", delimiter:".")
  end

  # esto es para validar el formato y el tamaño de la imagen
  private

  def acceptable_images
    return unless images.attached?

    images.each do |img|
      unless img.content_type.in?(%w[image/jpeg image/jpg image/png image/webp])
        errors.add(:images, "deben ser JPEG, PNG o WEBP")
      end
      if img.byte_size > 5.megabytes
        errors.add(:images, "cada archivo debe pesar menos de 5 MB")
      end
    end
  end

end
