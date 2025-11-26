class User < ApplicationRecord

  # relacion favoritos
  has_many :favorites, dependent: :destroy
  has_many :favorite_products, through: :favorites, source: :product

  # relacion con de carrito con usuario
  has_one :cart, dependent: :destroy

  # relacion con compras
  has_many :buys, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :purchasedetails, through: :buys, dependent: :destroy

  after_create :crear_carrito

    ROLES = %w[admin moderator user]

  def admin?
    role == "admin"
  end

  def moderator?
    role == "moderator"
  end

  def user?
    role == "user"
  end

  def has_purchased?(product)
    purchasedetails.exists?(product_id: product.id)
  end

  private

  def crear_carrito
    Cart.create(user: self)
  end
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :name, presence: true
  
  # Validación de complejidad de contraseña
  validate :password_complexity, if: -> { password.present? }

  def password_complexity
    return if password.blank?
    
    errors.add :password, 'debe tener al menos 6 caracteres' if password.length < 6
    errors.add :password, 'debe contener al menos una letra mayúscula' unless password.match(/[A-Z]/)
    errors.add :password, 'debe contener al menos una letra minúscula' unless password.match(/[a-z]/)
    errors.add :password, 'debe contener al menos un número' unless password.match(/[0-9]/)
  end

  # Método para verificar si el código de recuperación es válido
  def recovery_code_valid?(code)
    return false if recovery_code.nil? || recovery_code_sent_at.nil?
    return false if code != recovery_code
    
    # Verificar que no hayan pasado más de 15 minutos
    Time.current - recovery_code_sent_at < 15.minutes
  end

  # Método para limpiar el código después de usarlo
  def clear_recovery_code
    update(recovery_code: nil, recovery_code_sent_at: nil)
  end
end
