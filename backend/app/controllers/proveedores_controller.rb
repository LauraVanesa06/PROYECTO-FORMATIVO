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
    @productos = Producto.all
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
    redirect_to proveedores_path, notice: "Proveedor creado exitosamente."
 #   redirect_to @producto
 
  else
    render :new
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

def proveedor_params
  params.require(:proveedor).permit(:nombre, :ubicacion, :tipo_producto, :numero, :correo_electronico)
end

end
