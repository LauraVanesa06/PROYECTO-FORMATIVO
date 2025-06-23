class ProveedoresController < ApplicationController

before_action :authenticate_user!
before_action :only_admins

private

def only_admins
  unless current_user&.admin?
    redirect_to root_path, alert: "Acceso no autorizado"
  end
end


 def index
    @proveedores = Proveedor.all
    @proveedor = Proveedor.new
  end

  def show
    @producto = Producto.find(params[:id])
  end


def new
  @proveedor = Proveedor.new
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
  params.require(:product).permit(:nombre, :descripcion, :stock, :proveedor_id, ...)
end
def edit
    @producto = Producto.find(params[:id])
  end

  def update
    @producto = Producto.find(params[:id])
    if @producto.update(producto_params)
      redirect_to @producto
    else
      render :edit
    end
  end

  def destroy
    @producto = Producto.find(params[:id])
    @producto.destroy
    redirect_to productos_path
  end


private

 private

  def proveedor_params
    params.require(:proveedor).permit(:nombre, :direccion, :tipoProducto, :telefono, :correo)
  end

end
