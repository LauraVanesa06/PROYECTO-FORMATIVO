class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]
  layout false


  # GET /products or /products.json
  def index
    puts "params: #{params.inspect}"

    @products = Product.all
    @suppliers = Supplier.all

    #if params[:name].present? || params[:min].present? || params[:max].present? || params[:supplier_id].present?
      @products = @products.where("nombre LIKE ? ", "%#{params[:name]}%") if params[:name].present?
      @products = @products.where("precio >= ?", params[:min]) if params[:min].present?
      @products = @products.where("precio <= ?", params[:max]) if params[:max].present?
      @products = @products.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present?
    
      if @products.empty?
        flash.now[:alert] = "¡No se encontraron productos con esos filtros!"
        @products = Product.all
      end
    #end

    @categories = Category.all
    
    if params[:category_id].present?
      @category = Category.find(params[:category_id])
      @products = @category.products
    end
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
    @product = Product.find(params[:id])
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    if @product.save
      if params[:product][:images]
        @product.images.attach(params[:product][:images])
      end
      redirect_to products_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
  # Adjuntar nuevas imágenes (si el usuario subió más)
    if params[:product][:images].present?
      params[:product][:images].each do |img|
        @product.images.attach(img)  # 👉 esto las acumula en lugar de reemplazar
      end
    end

    # Borrar imágenes si se marcaron
    if params[:product][:remove_image_ids].present?
      params[:product][:remove_image_ids].each do |id|
        image = @product.images.attachments.find(id)
        image.purge
      end
    end

    # Actualizar solo los demás atributos (sin tocar :images)
    respond_to do |format|
      if @product.update(product_params.except(:images, :remove_image_ids))
        format.html { redirect_to inventario_path, notice: "Producto actualizado correctamente." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_disponibilidad
    # Obtiene el ID del producto desde el campo oculto
    product_to_update_id = params[:product_id]

    # Si el product_to_update_id no existe, algo está mal, sal de la acción
    return unless product_to_update_id.present?

    # Busca el producto
    product = Product.find(product_to_update_id)

    # El estado de `disponible` será verdadero si el checkbox estaba marcado (su ID está en el array).
    # `params[:disponibles_ids]` contiene los valores del checkbox y del hidden_field.
    # Si el checkbox está marcado, el array será ["0", "id_del_producto"].
    # Si está desmarcado, el array será ["0"].
    is_checked = params[:disponibles_ids].include?(product.id.to_s)
    
    product.update(disponible: is_checked)

    redirect_to inventario_path
  end

  def generate_code
    nombre = params[:nombre].to_s.strip
    code = ""

    if nombre.present?
      initials = nombre.split.map { |word| word[0] }.join.upcase
      last_product = Product.where("codigo_producto LIKE ?", "#{initials}%").order(:codigo_producto).last
      last_number = last_product.present? ? last_product.codigo_producto.gsub(initials, "").to_i : 0
      next_number = last_number + 1
      code = "#{initials}#{next_number.to_s.rjust(3, '0')}"
    end

    render json: { codigo: code }
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def purchasedetails
    @product = Product.find(params[:id])
    @purchasedetails = @product.purchasedetails
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(:nombre, :descripcion, :disponible, :precio, :stock,
       :category_id, :supplier_id, images: [], remove_image_ids: [], :codigo_producto, :cantidad, :modelo, :marca_id)
    end
end
