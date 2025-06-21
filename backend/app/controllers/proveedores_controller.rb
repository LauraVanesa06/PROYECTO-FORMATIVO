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
    @proveedor = Proveedor.new(proveedor_params)
    if @proveedor.save
      redirect_to proveedores_path, notice: 'Proveedor creado con éxito'
    else
      @proveedores = Proveedor.all
      render :index
    end
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
