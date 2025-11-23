class User < ApplicationRecord

  # relacion favoritos
  has_many :favorites, dependent: :destroy
  has_many :favorite_products, through: :favorites, source: :product

  # relacion con de carrito con usuario
  has_one :cart, dependent: :destroy

  # relacion con compras
  has_many :buys, dependent: :destroy
  has_many :payments, dependent: :destroy

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
end
