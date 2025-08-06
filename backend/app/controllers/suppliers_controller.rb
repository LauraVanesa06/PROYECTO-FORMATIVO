class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :only_admins
  layout false


  def only_admins
    unless current_user&.admin?
      redirect_to root_path, alert: "Acceso no autorizado"
    end
  end


  def index
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

  def show
    @product = Product.find(params[:id])
  end


  def new
    @supplier = Supplier.new
  end

def crear_supplier
  @supplier = Supplier.new(suppliers_params)

  if @supplier.save
    product_name = params[:nombre_product]
    stock = params[:stock].to_i
    supplier_nombre = @supplier.nombre

    # Buscar si ya existe un producto con ese nombre y proveedor con ese nombre
    product = Product.joins(:supplier)
                                .where(nombre: product_name, suppliers: { nombre: supplier_nombre })
                                .first

    if product
      # Solo aumentar el stock del producto existente
      product.increment!(:stock, stock)
    else
      # Crear producto nuevo y asociarlo al proveedor recien creado
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

  if @supplier.update(suppliers_params)
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



  def product_params
    params.require(:product).permit(:nombre, :descripcion, :stock, :supplier_id)
  end
  def edit
      @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to @product
    else
      render :edit
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path
  end


  private 

  def suppliers_params
    params.require(:supplier).permit(:nombre, :contacto)
  end

end