class HomeController < ApplicationController
  layout "application"
  skip_before_action :authenticate_user!, only: [:index, :producto, :contacto, :producto_show] # Añadir producto_show aquí

  def index
    @categories = Category.all
    
    # Solo mostrar productos disponibles en la vista pública
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @productos = @category.products.where(disponible: true)
    else
      @productos = Product.where(disponible: true)
    end
    
    # Aplicar filtros adicionales si existen
    if params[:search].present?
      @productos = @productos.where("LOWER(nombre) LIKE ? OR LOWER(descripcion) LIKE ?", 
                                  "%#{params[:search].downcase}%", 
                                  "%#{params[:search].downcase}%")
    end
    
    # Ordenar productos
    @productos = @productos.order(created_at: :desc)
  end

  def producto
    # Solo productos disponibles para clientes
    @productos = Product.where(disponible: true)
    @categories = Category.all
    @suppliers = Supplier.all

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

    # Si no hay productos después de los filtros, mostrar mensaje
    if @productos.empty?
      flash.now[:alert] = "No se encontraron productos disponibles con esos filtros."
    end
  end

  def producto_show
    @product = Product.find(params[:id])
    
    # Solo mostrar si está disponible (o si es admin)
    unless @product.disponible || current_user&.admin?
      redirect_to root_path, alert: "Este producto no está disponible actualmente"
      return
    end
    
    # Productos relacionados solo disponibles
    @relacionados = Product.where(category: @product.category, disponible: true)
                          .where.not(id: @product.id)
                          .limit(5)
    
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
