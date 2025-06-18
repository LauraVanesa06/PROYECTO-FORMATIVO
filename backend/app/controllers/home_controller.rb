class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @category = Category.all
  end

  def producto
    @categories = Category.includes(:products)
  end

  def contacto
  end
end
