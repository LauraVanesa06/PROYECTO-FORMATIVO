class PedidosController < ApplicationController
  before_action :set_pedido, only: %i[ show edit update destroy ]
  layout false

  # GET /pedidos or /pedidos.json
  def index
    @suppliers = Supplier.order(created_at: :desc)
    @supplier  = Supplier.new

    # Base: todos los pedidos hasta la fecha actual
    base_scope = Pedido.where('fecha <= ?', Time.current)

    filtered = base_scope

    # Filtro por supplier_id (si viene)
    filtered = filtered.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present?

    # Filtro por nombre de proveedor (si viene)
    if params[:name].present?
      filtered = filtered.joins(:supplier).where("suppliers.nombre LIKE ?", "%#{params[:name]}%")
      @suppliers = @suppliers.where("nombre LIKE ?", "%#{params[:name]}%")
    end

    if filtered.exists?
      @pedidos = filtered.order(fecha: :desc)
    else
      flash.now[:alert] = "No se encontraron pedidos con esos filtros. Se mostrarán todos los pedidos."
      @pedidos = base_scope.order(fecha: :desc)
    end

    if request.headers["Turbo-Frame"].present?
      render partial: "pedidos/pedidos_list", locals: { pedidos: @pedidos }
    else
      render :index
    end

  end

  # GET /pedidos/1 or /pedidos/1.json
  def show
  end

  # GET /pedidos/new
  def new
    @pedido = Pedido.new
  end

  # GET /pedidos/1/edit
  def edit
  end

  # POST /pedidos or /pedidos.json
  def create
    @pedido = Pedido.new(pedido_params)

    respond_to do |format|
      if @pedido.save
        format.html { redirect_to @pedido, notice: "Pedido was successfully created." }
        format.json { render :show, status: :created, location: @pedido }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pedido.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pedidos/1 or /pedidos/1.json
  def update
    respond_to do |format|
      if @pedido.update(pedido_params)
        format.html { redirect_to @pedido, notice: "Pedido was successfully updated." }
        format.json { render :show, status: :ok, location: @pedido }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pedido.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pedidos/1 or /pedidos/1.json
  def destroy
    @pedido.destroy!

    respond_to do |format|
      format.html { redirect_to pedidos_path, status: :see_other, notice: "Pedido was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pedido
      @pedido = Pedido.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pedido_params
      params.expect(pedido: [ :fecha, :productos, :descripcion_entrega, :supplier_id ])
    end
end
