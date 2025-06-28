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
    if params[:supplier_id].present?
      @products = @products.where(supplier_id: params[:supplier_id])
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



  def suppliers
    @products = Product.all
    @supplier_form = Supplier.new
    @suppliers = Supplier.includes(:products).all
    @supplier = Supplier.new
    @products_supplier = []
    @categorias = Category.all
 


    
    if params[:products_id].present?
      @suppliers = @suppliers.where(product_id: params[:product_id])
    end

    # Filtro por nombre desde el sidebar
    if params[:nombre].present?
      @suppliers = Supplier.where(nombre: params[:nombre]).includes(:products)
    else
      @suppliers = Supplier.includes(:products).all
    end
    # Filtros por ID o búsqueda por nombre (filtros del formulario superior)
    @suppliers = @suppliers.where(id: params[:id]) if params[:id].present?
    @suppliers = @suppliers.where("nombre LIKE ?", "%#{params[:name]}%") if params[:name].present?

    # Para mostrar productos en tarjetas
        @products_supplier = @suppliers.flat_map(&:products)


    # Usado para vista si no hay resultados
    @filter_result_empty = @suppliers.blank?
    if params[:supplier_id].present?
      @supplier = Supplier.find_by(id: params[:supplier_id])
      @products_supplier = @suppliers&.products || []
    elsif @suppliers.size == 1
      @supplier = @suppliers.first
      @products_supplier = @supplier.products
    else
      @products_supplier = Supplier.includes(:supplier).all
      @supplier = Supplier.new # <-- asegúrate de que esto esté siempre definido al final
    end

  end

  def crear_supplier
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      # Busca producto por nombre y proveedor
      product_name = params[:nombre_product].strip
      stock = params[:stock].to_i
      categoria_id = params[:category_id]

      
      producto = Product.joins(:supplier)
                  .find_by(nombre: product_name, suppliers: { nombre: @supplier.nombre })

 

    if producto
      producto.increment!(:stock, stock)
    else
      # Crear producto asociado al proveedor
      Product.create!(
        nombre: product_name,
        stock: stock,
        supplier_id: @supplier.id,
          category_id: categoria_id,
      )
    end 


      redirect_to dashboard_suppliers_path, notice: "Proveedor y producto registrados."
    else
      @suppliers = Supplier.includes(:product)
      render :suppliers
    end
  end
  def actualizar_supplier
    @supplier = Supplier.find(params[:id])
    if @supplier.update(supplier_params)
      redirect_to dashboard_suppliers_path, notice: "Proveedor actualizado"
    else
      redirect_to dashboard_suppliers_path, alert: "Error al actualizar proveedor"
    end
  end
  
    private

    def supplier_params
      params.require(:supplier).permit(:nombre, :direccion, :tipoProducto, :telefono, :correo)
    end
end



