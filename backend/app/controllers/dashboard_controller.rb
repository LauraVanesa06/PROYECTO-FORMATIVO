class DashboardController < ApplicationController
  layout false
  def index
  end

  def inventario
    @categories = Category.all
    @products = Product.all
    @suppliers = Supplier.all
  end
end