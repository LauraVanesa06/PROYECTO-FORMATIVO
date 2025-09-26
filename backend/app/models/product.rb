class Product < ApplicationRecord
  # Relacion favoritos
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user, dependent: :destroy

  # Relacion carrito
  has_many :cart_items, dependent: :destroy

  # realciones
  belongs_to :category
  belongs_to :supplier
  belongs_to :marca
  has_many :purchasedetails, dependent: :destroy
  validates :nombre, uniqueness: { scope: :supplier_id }
  validates :precio, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :marca_id, presence: true

  # codigo del producto
  before_validation :generar_codigo_producto, on: :create
  before_create :generate_code
  validates :codigo_producto, uniqueness: true
  before_update :preserve_code
  attr_readonly :codigo_producto

  # imagen
  has_many_attached :images, dependent: :purge
  validate :acceptable_images
  

  private

  def precio_cop
    ApplicationController.helpers.number_to_currency(precio, unit: "", separator: ",", delimiter:".")
  end

  # esto es para validar el formato y el tamaño de la imagen
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
  
  # esto es para generar el codigo del producto automaticamente
  def generate_code
    loop do
      initials = nombre.split.map { |word| word[0] }.join.upcase
      last_product = Product.where("codigo_producto LIKE ?", "#{initials}%").order(:codigo_producto).last
      last_number = last_product.present? ? last_product.codigo_producto.gsub(initials, "").to_i : 0
      next_number = last_number + 1
      candidate = "#{initials}#{next_number.to_s.rjust(3, '0')}"

      unless Product.exists?(codigo_producto: candidate)
        self.codigo_producto = candidate
        break
      end
    end
  end

  def preserve_code
    self.codigo_producto = codigo_producto_was if codigo_producto_changed?
  end

  def generar_codigo_producto
    # Solo lo genera si está vacío
    self.codigo_producto ||= "P-#{SecureRandom.hex(4).upcase}"
  end

end
