class Api::V1::ProductosController < ApplicationController
    skip_before_action :authenticate_user!
    def index
        productos = Product.all
        render json: productos
    end
end
