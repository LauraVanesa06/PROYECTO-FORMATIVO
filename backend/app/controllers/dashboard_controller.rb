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

    # Filtro por proveedores (si existe un parámetro de supplier_ids)
    if params[:proveedor_id].present?
      @products = @products.where(supplier_id: params[:proveedor_id])
    end

    @categories = Category.all
    
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @products = @category.products
    end
  end
  layout false

  before_action :authenticate_user!
  before_action :only_admins

  def only_admins
    redirect_to authenticated_root_path, alert: "No autorizado" unless current_user&.admin?
  end
  
  def ventas
    @purchasedetails = Purchasedetail.all
    @purchasedetails = Purchasedetail.joins("INNER JOIN buys ON buys.id = purchasedetails.buy_id")

    if params[:id].present?
      @purchasedetails = @purchasedetails.where("buys.id = ?", params[:id])
    end

    if params[:year].present? || params[:month].present? || params[:day].present?
      conditions = []
      values = []

      if params[:year].present?
        conditions << "strftime('%Y', buys.fecha) = ?"
        values << params[:year]
      end

      if params[:month].present?
        conditions << "strftime('%m', buys.fecha) = ?"
        values << params[:month].rjust(2, '0')
      end

      if params[:day].present?
        conditions << "strftime('%d', buys.fecha) = ?"
        values << params[:day].rjust(2, '0')
      end

      @purchasedetails = @purchasedetails.where(conditions.join(" AND "), *values)
    end
  end

  def proveedores

  end

  def clientes
    @customers = Customer.all 
    @purchasedetails = Purchasedetail.all

    if params[:customer_id].present?
      @customer = Customer.find_by(id: params[:customer_id])
      if @customer
        @purchasedetails = @customer.purchasedetails.includes(:product, buy: :customer)
      end
    end

    @customers = Customer.left_outer_joins(:buys).distinct.includes(:buys)
    @customer = nil
    @purchasedetails = []

    if params[:id].present?
      @customers = @customers.where(id: params[:id])
    end

    if params[:name].present?
      @customers = @customers.where("nombre LIKE ?", "%#{params[:name]}%")
    end
    
    if @customers.size == 1
      @customer = @customers.first
      @purchasedetails = @customer.purchasedetails.includes(:product, buy: :customer)
    end

    @filter_result_empty = @customers.blank?  

  end  
end