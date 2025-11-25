class HomeController < ApplicationController
  include Pagy::Backend
  layout "application"
  skip_before_action :authenticate_user!, only: [:index, :producto, :contacto, :producto_show, :restore_images]

  def restore_images
    puts "🔗 Revinculando imágenes antiguas..."
    
    # Obtener los blobs huérfanos (sin attachment)
    orphan_blobs = ActiveStorage::Blob.where.not(id: ActiveStorage::Attachment.select(:blob_id))
    
    puts "Blobs huérfanos: #{orphan_blobs.count}"
    
    relinked_count = 0
    
    orphan_blobs.each do |blob|
      # Extraer el nombre del producto del filename
      filename = blob.filename.to_s
      puts "  Procesando: #{filename}"
      
      # Intentar encontrar un producto cuyo nombre coincida
      # Por ejemplo: "Martillo" o "martillo-ef7a0562.jpg" 
      product_name = filename.split('-').first.capitalize
      
      product = Product.where("LOWER(nombre) LIKE ?", "%#{product_name}%").first
      
      if product
        # Crear un nuevo attachment vinculando el blob con el producto
        ActiveStorage::Attachment.create(
          name: 'images',
          record_type: 'Product',
          record_id: product.id,
          blob_id: blob.id
        )
        puts "    ✓ Vinculado a: #{product.nombre}"
        relinked_count += 1
      else
        puts "    ✗ No se encontró producto para: #{filename}"
      end
    end
    
    render plain: "✅ Se revincularon #{relinked_count} imágenes\n\nRecarga la página para ver los cambios."
  end # Añadir producto_show aquí

  def index
    # OPTIMIZACIÓN: Cachear categorías (raramente cambian)
    @categories = Rails.cache.fetch("categories:all", expires_in: 24.hours) do
      Category.includes(:imagen_attachment).limit(10).to_a
    end
    
    # Solo mostrar productos disponibles en la vista pública
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @productos = @category.products.where(disponible: true)
    else
      @productos = Product.where(disponible: true)
    end
    
    # OPTIMIZACIÓN: Eager load de marca y categoría (evita N+1 queries)
    @productos = @productos.includes(:marca, :category)
    
    # Aplicar filtros adicionales si existen
    if params[:search].present?
      @productos = @productos.where("LOWER(nombre) LIKE ? OR LOWER(descripcion) LIKE ?", 
                                  "%#{params[:search].downcase}%", 
                                  "%#{params[:search].downcase}%")
    end
    
    # Ordenar y paginar con Pagy (ultraligero)
    @productos = @productos.order(created_at: :desc)
    @pagy, @productos = pagy(@productos, items: 12)
  end

  def producto
    # OPTIMIZACIÓN: Cachear categorías y suppliers (raramente cambian)
    @categories = Rails.cache.fetch("categories:all", expires_in: 24.hours) do
      Category.includes(:imagen_attachment).limit(10).to_a
    end
    @suppliers = Rails.cache.fetch("suppliers:all", expires_in: 24.hours) do
      Supplier.select(:id, :nombre).limit(5).to_a
    end
    
    # Solo productos disponibles para clientes con eager loading de imágenes
    @productos = Product.where(disponible: true)
                       .includes(:marca, :category, :images_attachments)

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

    # Ordenar productos
    @productos = @productos.order(created_at: :desc)
    
    # PAGINACIÓN: 12 productos por página
    @pagy, @productos = pagy(@productos, items: 12)

    # Si no hay productos después de los filtros, mostrar mensaje
    if @productos.empty?
      flash.now[:alert] = "No se encontraron productos disponibles con esos filtros."
    end
  end

  def producto_show
    # Eager load de imágenes y relaciones para optimizar
    @product = Product.includes(:images_attachments, :marca, :category).find(params[:id])
    
    # Solo mostrar si está disponible (o si es admin)
    unless @product.disponible || current_user&.admin?
      redirect_to root_path, alert: "Este producto no está disponible actualmente"
      return
    end
    
    # Productos relacionados solo disponibles con eager loading
    @relacionados = Product.where(category: @product.category, disponible: true)
                          .where.not(id: @product.id)
                          .includes(:images_attachments, :marca)
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
