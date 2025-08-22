class Api::V1::ProductsController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    products = Product.all
    render json: products.map { |product|
    product.as_json.merge(
      imagen_url: product.imagen.attached? ? url_for(product.imagen) : nil
    )
  }
  end
end
