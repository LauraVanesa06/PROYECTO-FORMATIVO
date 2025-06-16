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
     format.html { redirect_to proveedores_path, notice: "Customer was successfully created." }
      format.json { render :show, status: :created, location: @customer }
  #  redirect_to proveedores_path, notice: "Proveedor creado exitosamente."
 #   redirect_to @producto
 
  else
    render :new
  end
end

def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
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


#



  # POST /customers or /customers.json
  

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: "Customer was successfully updated." }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy!

    respond_to do |format|
      format.html { redirect_to customers_path, status: :see_other, notice: "Customer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def buys
    @customer = Customer.find(params[:id])
    @buys = @customer.buys
  end

  def purchasedetails
  @customer = Customer.find(params[:id])
  @purchasedetails = @customer.purchasedetails
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.expect(customer: [ :nombre, :telefono ])
    end
end
