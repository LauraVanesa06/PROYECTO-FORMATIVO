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
      @products = @products.where(proveedor_id: params[:proveedor_id])
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
    @buys = Buy.all
    @purchasedetails = Purchasedetail.all
    @purchasedetails = Purchasedetail.joins("INNER JOIN buys ON buys.id = purchasedetails.buy_id")

    if params[:id].present?
      @buys = @buys.where("buys.id = ?", params[:id])
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

      @buys = @buys.where(conditions.join(" AND "), *values)
    end
  end

  def clientes
    @customers = Customer.all
    @customer = nil
    @purchasedetails = []
    @buys = Buy.all

    if params[:documento].present?
      doc = params[:documento].to_i
      @customers = @customers.where(documento: doc)
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

      @buys = @buys.where(conditions.join(" AND "), *values)
    end

    buy_ids = @buys.pluck(:id)

    @customers = @customers.left_outer_joins(:buys).distinct.includes(:buys)

    if params[:customer_id].present?
      @customer = Customer.find_by(id: params[:customer_id])
      @purchasedetails = @customer&.purchasedetails&.includes(:productos, buy: :customer) || []

    elsif params[:id].blank? && params[:name].blank?
      @purchasedetails = Purchasedetail.includes(:productos, buy: :customer).all

    elsif @customers.size == 1
      @customer = @customers.first
      @purchasedetails = @customer.purchasedetails.includes(:productos, buy: :customer)

      @purchasedetails = @customer&.purchasedetails&.includes(:product, buy: :customer) || []
      @purchasedetails = @purchasedetails.where(buy_id: buy_ids) if buy_ids.present?

    elsif params[:id].blank? && params[:name].blank? && params[:documento].blank?
      @purchasedetails = Purchasedetail.includes(:product, buy: :customer)
      @purchasedetails = @purchasedetails.where(buy_id: buy_ids) if buy_ids.present?

    elsif @customers.size == 1
      @customer = @customers.first
      @purchasedetails = @customer.purchasedetails.includes(:product, buy: :customer)
      @purchasedetails = @purchasedetails.where(buy_id: buy_ids) if buy_ids.present?

    end

    @filter_result_empty = @customers.blank?
  end



  def proveedores
    @products = Product.all
    @proveedor_form = Proveedor.new
    
    if params[:productos_id].present?
      @proveedores = @proveedores.where(producto_id: params[:producto_id])
    end

    # Filtro por nombre desde el sidebar
    if params[:nombre].present?
      @proveedores = Proveedor.where(nombre: params[:nombre]).includes(:productos)
    else
      @proveedores = Proveedor.includes(:productos).all
    end
    # Filtros por ID o búsqueda por nombre (filtros del formulario superior)
    @proveedores = @proveedores.where(id: params[:id]) if params[:id].present?
    @proveedores = @proveedores.where("nombre LIKE ?", "%#{params[:name]}%") if params[:name].present?

    # Para mostrar productos en tarjetas
    @productos_proveedor = @proveedores.flat_map(&:productos)

    # Usado para vista si no hay resultados
    @filter_result_empty = @proveedores.blank?
    if params[:proveedor_id].present?
      @proveedor = Proveedor.find_by(id: params[:proveedor_id])
      @productos_proveedor = @proveedor&.productos || []
    elsif @proveedores.size == 1
      @proveedor = @proveedores.first
      @productos_proveedor = @proveedor.productos
    else
      @productos_proveedor = Product.includes(:proveedor).all
      @proveedor = Proveedor.new # <-- asegúrate de que esto esté siempre definido al final
    end

  end

  def crear_proveedor
    @proveedor = Proveedor.new(proveedor_params)

    if @proveedor.save
      # Busca producto por nombre y proveedor
      producto = Product.find_by(nombre: params[:nombre_product], proveedor_id: @proveedor.id)

      if producto
        producto.increment!(:stock, params[:stock].to_i)
      else
        Product.create(nombre: params[:nombre_product], stock: params[:stock], proveedor_id: @proveedor.id)
      end

      redirect_to dashboard_proveedores_path, notice: "Proveedor y producto registrados."
    else
      @proveedores = Proveedor.includes(:productos).all
      render :proveedores
    end
  end
def actualizar_proveedor
  @proveedor = Proveedor.find(params[:id])
  if @proveedor.update(proveedor_params)
    redirect_to dashboard_proveedores_path, notice: "Proveedor actualizado"
  else
    redirect_to dashboard_proveedores_path, alert: "Error al actualizar proveedor"
  end
end
  
    private

    def proveedor_params
      params.require(:proveedor).permit(:nombre, :direccion, :tipoProducto, :telefono, :correo)
    end
end


end

