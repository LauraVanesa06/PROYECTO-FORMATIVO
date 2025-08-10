class User < ApplicationRecord

  # relacion con de carrito con usuario
  has_one :cart, dependent: :destroy


  after_create :crear_carrito

  private

  def crear_carrito
    Cart.create(user: self)
  end
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


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
end
