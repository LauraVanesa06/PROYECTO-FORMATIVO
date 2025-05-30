class ProveedoresController < ApplicationController


def new
  @proveedor = Proveedor.new
end


def create
  @proveedor = Proveedor.new(proveedor_params)
  if @proveedor.save
    redirect_to proveedores_path, notice: "Proveedor creado exitosamente."
  else
    render :new
  end
end

private

def proveedor_params
  params.require(:proveedor).permit(:nombre, :ubicacion, :tipo_producto, :numero, :correo_electronico)
end

end
