class ProductosController < ApplicationController
    skip_before_action :authenticate_user!, onli: [:productos]
    def producto
    end
end
