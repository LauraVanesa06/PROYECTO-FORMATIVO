class ContactosController < ApplicationController
  skip_before_action :authenticate_user!, onli: [:contactos]
  def contacto
  end
end
