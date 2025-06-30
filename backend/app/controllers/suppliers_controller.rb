class SuppliersController < ApplicationController
  before_action :authenticate_user!
  before_action :only_admins

  private

  def only_admins
    unless current_user&.admin?
      redirect_to root_path, alert: "Acceso no autorizado"
    end
  end


  def index
    @suppliers = Supplier.all
    @supplier = Supplier.new
  end

  def show
    @product = Product.find(params[:id])
  end


  def new
    @supplier = Supplier.new
  end

def crear_supplier
  @supplier = Supplier.new(supplier_params)

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


  private

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