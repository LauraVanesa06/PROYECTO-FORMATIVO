class Api::V1::ProductsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    # Permite recibir tanto category_id (Rails style) como categoryId (Flutter style)
    category_param = params[:category_id] || params[:categoryId]

    if category_param.present?
      products = Product.where(category_id: category_param)
    else
      # Si no hay categoría, devolvemos los 8 productos más comprados
      products = Product
        .left_joins(:purchasedetails)
        .group('products.id')
        .select('products.*, COALESCE(SUM(purchasedetails.cantidad), 0) AS total_comprados')
        .order('total_comprados DESC')
        .limit(8)
    end

    render json: products.map { |product|
          {
        id: product.id,
        nombre: product.nombre,
        descripcion: product.descripcion,
        precio: product.precio,
        stock: product.stock,
        category_id: product.category_id,
        categoria: product.category&.nombre,
        total_comprados: (product.try(:total_comprados) || 0).to_i,
        imagen_url: product.images.attached? ? url_for(product.images.first) : "NO_IMAGE",
        has_images: product.images.attached?,
        images_count: product.images.count
      }
      product_json(product)
    }
  end

  # Nueva acción: obtener todos los productos sin límite
  def all_products
    products = Product.all.includes(:category, images_attachments: :blob)

    render json: products.map { |product|
      product_json(product)
    }
  end

  private

  # Método auxiliar para evitar repetir el mismo formato JSON
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
      imagen_url: product.images.attached? ? url_for(product.images.first) : "NO_IMAGE",
      has_images: product.images.attached?,
      images_count: product.images.count
    }
  end
end
