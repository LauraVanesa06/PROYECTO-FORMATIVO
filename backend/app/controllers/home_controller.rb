class HomeController < ApplicationController
  layout "application"
  skip_before_action :authenticate_user!, only: [:index, :producto, :contacto]

  def index
    @categories = Category.all
    @productos = Product
      .joins(:purchasedetails)
      .select("products.*, SUM(purchasedetails.cantidad) AS total_vendidos")
      .group("products.id")
      .order("total_vendidos DESC")
      .limit(8) # cantidad que quieras mostrar
  end

  def producto
    @productos = Product.all
    @categories = Category.all
    @suppliers  = Supplier.all

    if params[:category_id].present?
      @productos = @productos.where(category_id: params[:category_id])
    end

    if params[:query].present?
      query = params[:query].downcase
      @productos = @productos.where("LOWER(nombre) LIKE ?", "%#{query}%")
    end

    if params[:min_price].present?
      @productos = @productos.where("precio >= ?", params[:min_price])
    end

    if params[:max_price].present?
      @productos = @productos.where("precio <= ?", params[:max_price])
    end
  end

  def producto_show
    @product = Product.find(params[:id])
    @relacionados = Product.where(category: @product.category).where.not(id: @product.id).limit(4)
    
    # Variables para Wompi en producto individual
    @payment_reference = "product_#{@product.id}_#{Time.current.to_i}"
    @signature = "" # Para testing, en producción debes generar la signature
  end

  def send_report
    @user_support = UserSupport.new(user_support_params)

    if @user_support.save
      ContactarAdministradorMailer.reporte_duda(@user_support).deliver_now
      ContactarAdministradorMailer.confirmar_user(@user_support).deliver_now

      flash[:notice] = "Tu mensaje fue enviado correctamente."
      redirect_to contactos_path(sent: true)
    else
      flash[:alert] = "Hubo un error al enviar el mensaje."
      render :new
    end
  end

  private

  def user_support_params
    params.require(:user_support).permit(:user_name, :user_apellido, :user_email, :description)
  end
end
