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
    @productos = Product.all
  end

  # GET /pedidos/1/edit
  def edit
  end

  # POST /pedidos or /pedidos.json
  def create
    # Buscar el proveedor por código_proveedor
    codigo = params[:codigo_proveedor]
    supplier = Supplier.find_by(codigo_proveedor: codigo)
    @pedido = Pedido.new(pedido_params)
    @pedido.supplier = supplier if supplier

    if @pedido.save
      # Crear las relaciones con los productos seleccionados y actualizar stock
      if params[:pedido][:productos]
        params[:pedido][:productos].each do |product_id|
          cantidad = params[:pedido][:cantidades][product_id]
          PedidoProduct.create(pedido: @pedido, product_id: product_id, cantidad: cantidad)
          # Actualizar el stock del producto
          producto = Product.find_by(id: product_id)
          if producto && cantidad.present?
            producto.increment!(:stock, cantidad.to_i)
          end
        end
      end

      # Notificación al proveedor
      proveedor = @pedido.supplier
      if proveedor&.correo.present?
        PedidoMailer.notificar_proveedor(@pedido).deliver_later
      elsif proveedor&.contacto.present?
        # Mensaje de texto (SMS) usando el servicio SmsSender
        productos_info = @pedido.pedido_products.includes(:product).map { |pp| "#{pp.product.nombre} (#{pp.cantidad})" }.join(", ")
        sms_body = "Nuevo pedido recibido. Productos: #{productos_info}. Entrega: #{@pedido.descripcion_entrega}"
        SmsSender.send_sms(to: proveedor.contacto, body: sms_body)
      end

      redirect_to pedidos_path, notice: "Pedido creado correctamente"
    else
      @productos = Product.all
      render :new
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

  def actualizar_stock_productos
    Array(productos).each do |p|
      # Buscar si existe el producto
      producto = Product.find_by(id: p["product_id"])
      # ...resto del código...
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
