class CategoriesController < ApplicationController
  before_action :authenticate_user!, except: [:test]
  before_action :set_category, only: %i[ show edit update destroy ]

  # GET /categories or /categories.json
  def index
    @categories = Category.all
  end

  # GET /categories/test
  def test
    Rails.logger.info("TEST ACTION CALLED")
    @category = Category.new
    render :test_form, layout: false
  end

  # GET /categories/1 or /categories/1.json
  def show
  end

  # GET /categories/new
  def new
    @category = Category.new
  end

  # GET /categories/1/edit
  def edit
  end

  # POST /categories or /categories.json
  def create
    Rails.logger.info("CREATE ACTION CALLED WITH PARAMS: #{params.inspect}")
    @category = Category.new(category_params)
    
    Rails.logger.info("CategoryController#create - params: #{category_params.inspect}")
    Rails.logger.info("Category errors BEFORE save: #{@category.errors.inspect}") unless @category.save

    respond_to do |format|
      if @category.save
        Rails.logger.info("Category created successfully: #{@category.inspect}")
        format.html { redirect_to inventario_path, notice: "La Categoria fue Creada Exitosamente!" }
        format.json { render :show, status: :created, location: @category }
      else
        Rails.logger.error("Category creation failed - errors: #{@category.errors.full_messages}")
        format.html { redirect_to inventario_path, alert: "Error: #{@category.errors.full_messages.join(', ')}" }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    # Eliminar imagen si se solicita
    if params[:category][:remove_imagen] == 'true'
      @category.imagen.purge
    end

    respond_to do |format|
      if @category.update(category_params)
        format.html { redirect_to inventario_path, notice: "La Categoria fue Editada Exitosamente!" }
        format.json { render :show, status: :ok, location: @category }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @category.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    @category.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "La categoría fue eliminada exitosamente." }
      format.json { head :no_content }
    end
  end

  def products
    @category = Category.find(params[:id])
    @products = @category.products
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.require(:category).permit(:nombre, :imagen, :remove_imagen)
    end
    
end
