class Api::V1::ProductosController < ApplicationController
    def index
        productos = Product.all
        render json: productos
    end
end
