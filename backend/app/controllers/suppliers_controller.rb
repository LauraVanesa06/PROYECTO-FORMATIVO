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

  def create
    existing_product = Product.find_by(nombre: params[:product][:nombre])

    if existing_product
      # Ya existe → solo actualizar stock
      existing_product.increment!(:stock, params[:product][:stock].to_i)
      flash[:notice] = "Producto existente, se actualizó el stock."
    else
      # No existe → crear nuevo producto
      Product.create(product_params)
      flash[:notice] = "Producto creado correctamente."
    end

    redirect_to dashboard_proveedores_path
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