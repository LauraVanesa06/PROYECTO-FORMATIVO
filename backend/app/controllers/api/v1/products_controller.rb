class Api::V1::ProductsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if params[:category_id].present?
      products = Product.where(category_id: params[:category_id])
    else
      # Si no hay categoría, traemos los 8 más comprados
      products = Product
        .left_joins(:purchasedetails)
        .group('products.id')
        .select('products.*, COALESCE(SUM(purchasedetails.cantidad), 0) AS total_comprados')
        .order('total_comprados DESC')
        .limit(8)
    end

    render json: products.map { |product|
      product.as_json.merge(
        total_comprados: (product.try(:total_comprados) || 0).to_i,
        imagen_url: product.images.attached? ? url_for(product.images.first) : "NO_IMAGE",
        has_images: product.images.attached?,
        images_count: product.images.count,
        categoria: product.category&.nombre
      )
    }
  end
end
