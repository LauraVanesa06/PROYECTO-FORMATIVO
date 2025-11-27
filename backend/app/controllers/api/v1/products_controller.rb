class Api::V1::ProductsController < ApplicationController
  include Rails.application.routes.url_helpers
  skip_before_action :authenticate_user!, only: [:index, :all_products, :show]
  skip_before_action :verify_authenticity_token

  def index
    # Permite recibir tanto category_id (Rails style) como categoryId (Flutter style)
    category_param = params[:category_id] || params[:categoryId]

    if category_param.present?
      # 🔎 Filtrar por categoría
      products = Product.where(category_id: category_param)
    else
      # 🏆 Top 8 productos más comprados
      products = Product
        .left_joins(:purchasedetails)
        .group('products.id')
        .select('products.*, COALESCE(SUM(purchasedetails.cantidad), 0) AS total_comprados')
        .order('total_comprados DESC')
        .limit(8)
    end

    render json: products.map { |product| product_json(product) }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # 📌 Obtiene TODOS los productos (para el buscador)
  def all_products
    products = Product.all.includes(:category, images_attachments: :blob)

    render json: products.map { |product| product_json(product) }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # 📌 Mostrar detalle de producto
  def show
    product = Product.find(params[:id])
    render json: product_json(product)
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  # 🔧 Método auxiliar para devolver un único formato JSON
  def product_json(product)
    {
      id: product.id,
      nombre: product.nombre,
      descripcion: product.descripcion,
      precio: product.precio,
      stock: product.stock,
      category_id: product.category_id,
      categoria: product.category&.nombre,
      total_comprados: (product.try(:total_comprados) || 0).to_i,
      imagen_url: product.images.attached? ? rails_blob_url(product.images.first) : "NO_IMAGE",
      has_images: product.images.attached?,
      images_count: product.images.count
    }
  rescue => e
    Rails.logger.error "Error generando JSON para producto #{product.id}: #{e.message}"
    raise e
  end
end
