class Api::V1::ProductsController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    # Top 10 productos más comprados
    products = Product
      .left_joins(:purchasedetails)
      .group('products.id')
      .select('products.*, COALESCE(SUM(purchasedetails.cantidad), 0) AS total_comprados')
      .order('total_comprados DESC')
      .limit(8)

    render json: products.map { |product|
      product.as_json.merge(
        total_comprados: product.total_comprados.to_i,
        imagen_url: product.images.attached? ? url_for(product.images.first) : "NO_IMAGE",
        has_images: product.images.attached?,
        images_count: product.images.count
      )
    }
  end
end
