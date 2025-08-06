class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]
  layout false


  # GET /products or /products.json
  def index
    puts "params: #{params.inspect}"

    # Inicializamos los productos y proveedores
    @products = Product.all
    @suppliers = Supplier.all

    # Filtro por nombre (query)
    if params[:query].present?
      @products = @products.where("nombre LIKE ?", "%#{params[:query]}%")
    end

    # Filtro por precio mínimo
    if params[:min_price].present?
      @products = @products.where("precio >= ?", params[:min_price])
    end

    # Filtro por precio máximo
    if params[:max_price].present?
      @products = @products.where("precio <= ?", params[:max_price])
    end

    # Filtro por proveedores (si existe un parámetro de supplier_ids)
    if params[:supplier_id].present?
      @products = @products.where(supplier_id: params[:supplier_id])
    end

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
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to inventario_path, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
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
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.expect(product: [ :nombre, :descripcion, :precio, :stock, :category_id, :supplier_id, :imagen ])
    end
end
