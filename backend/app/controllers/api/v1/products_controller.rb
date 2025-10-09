class Api::V1::ProductsController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    products = Product.all
    render json: products.map { |product|
    product.as_json.merge(
      imagen_url: product.images.attached? ? product.images.map {|img| url_for(img)} : []
    )
  }
  end
end
