class DashboardController < ApplicationController
  layout false
  def index
  end


  def productos
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
      @purchasedetails = @customer&.purchasedetails&.includes(:product, buy: :customer) || []

    elsif params[:id].blank? && params[:name].blank?
      @purchasedetails = Purchasedetail.includes(:product, buy: :customer).all

    elsif @customers.size == 1
      @customer = @customers.first
      @purchasedetails = @customer.purchasedetails.includes(:product, buy: :customer)

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

    @supplier_form = Supplier.new
    @supplier = Supplier.new
    @categorias = Category.all
    @suppliers = Supplier.includes(:products).all
 
    if params[:nombre].present?
      @suppliers = Supplier.where(nombre: params[:nombre])
    else
      @suppliers = Supplier.all
    end
  
    # Filtro por ID
    if params[:id].present? && params[:id] != ""
      @suppliers = Supplier.where(id: params[:id])
    elsif params[:name].present? && params[:name] != ""
      @suppliers = Supplier.where("nombre ILIKE ?", "%#{params[:name]}%")
    else
      @suppliers = Supplier.all
    end

    @products_supplier = Product.where(supplier_id: @suppliers.pluck(:id))

    #Filtro por nombre (desde filtro del nav)
    if params[:name].present?
      @suppliers = @suppliers.where("nombre ILIKE ?", "%#{params[:name]}%")
    end


     # Asignación de proveedor específico si se envía un parámetro
 
    if @suppliers.size == 1
        @supplier = @suppliers.first
        @products_supplier = @supplier.products
      else
        @products_supplier = Product.includes(:supplier).all
      end
      # Bandera para mostrar mensaje si no hay resultados
      @filter_result_empty = @suppliers.blank?
  end


  def crear_supplier
    @supplier = Supplier.new(supplier_params)

    if @supplier.save
      product_name = params[:nombre_product]
      stock = params[:stock].to_i

      # Buscar si ya existe un producto con ese nombre y proveedor con ese nombre
      product = Product.joins(:supplier)
                                  .where(nombre: product_name, suppliers: { nombre: @supplier.nombre })
                                  .first

      if product
        #  aumentar el stock del producto 
        product.increment!(:stock, stock)
      else
        # Crear producto y asociarlo al proveedor nuevo
        Product.create!(
          nombre: product_name,
          stock: stock,
          supplier_id: @supplier.id
        )
      end
    end

    redirect_to dashboard_suppliers_path
  end

  def actualizar_supplier
  @supplier = Supplier.find(params[:id])

  if @supplier.update(supplier_params)
    product_name = params[:nombre_product].presence
    stock = params[:stock].to_i
    category_id = params[:category_id].presence
    category_id = category_id.to_i if category_id.present?

    if product_name && stock > 0
      existing_product = Product.find_by(nombre: product_name, supplier_id: @supplier.id)

      if existing_product
        existing_product.increment!(:stock, stock)
      else
        Product.create!(
          nombre: product_name,
          stock: stock,
          supplier_id: @supplier.id,
          category_id: category_id
        )
      end
    end

    redirect_to dashboard_suppliers_path, notice: "Proveedor y producto actualizados"
  else
    redirect_to dashboard_suppliers_path, alert: "Error al actualizar proveedor"
  end
end

  def help
  end
  def send_report
    @support_request = SupportRequest.new(support_request_params)


    if @support_request.save
    ContactarTecnicoMailer.reporte_error(@support_request).deliver_now
      ContactarTecnicoMailer.confirm_user(@support_request).deliver_now

    flash[:notice] = "Tu mensaje fue enviado correctamente."
    redirect_to help_path(sent: true)
  else

    flash[:alert] = "Hubo un error al enviar el mensaje."
    render :new
  
  end
    
end
  
  private

  def supplier_params
    params.require(:supplier).permit(:nombre, :contacto)
  end

 
  def support_request_params
  params.require(:support_request).permit(:user_name, :user_email, :description)
  end

  
end



