class DashboardController < ApplicationController
  layout false
  def index
  end

  def inventario
    @categories = Category.all
    @products = Product.all
  end
end