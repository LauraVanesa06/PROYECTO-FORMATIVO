class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  def index
  end

  def producto
  end

  def contacto
  end
end
