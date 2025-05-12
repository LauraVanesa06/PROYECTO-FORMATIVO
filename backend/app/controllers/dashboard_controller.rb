class DashboardController < ApplicationController
  layout false
  def index
  end

  def inventario
    # Debug: Muestra los parámetros en la consola
    puts "params: #{params.inspect}"

    # Inicializamos los productos y proveedores
    @products = Product.all
    @suppliers = Supplier.all

    # Filtro por nombre (query)
    if params[:query].present?
      @products = @products.where("nombre LIKE ?", "%#{params[:query]}%")
    end

    # Filtro por precio mínimo
    if params[:min_price].present?
      @products = @products.where("precio >= ?", params[:min_price])
    end

    # Filtro por precio máximo
    if params[:max_price].present?
      @products = @products.where("precio <= ?", params[:max_price])
    end

    # Filtro por proveedores (si existe un parámetro de `supplier_ids`)
    if params[:proveedor_id].present?
      @products = @products.where(supplier_id: params[:proveedor_id])
    end

    @categories = Category.all
    
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @products = @category.products
    end
  end
end