class BuysController < ApplicationController
  before_action :set_buy, only: %i[ show edit update destroy ]
  layout false

  # GET /buys or /buys.json
  def index
    # Base: todas las ventas con relaciones

    @buys = Buy.all.order(created_at: :desc)
    @buy = Buy.new
    @buys = Buy.includes(:payment, :user).order(fecha: :desc)
    @products = Product.all

    # Filtro por nombre de cliente (case-insensitive)
    if params[:customer].present?
      @buys = @buys.joins(:user).where("LOWER(users.name) LIKE ?", "%#{params[:customer].downcase}%")
    end

    # Filtro por fecha (año, mes, día) - Compatible con PostgreSQL y SQLite
    if params[:year].present?
      @buys = @buys.where("EXTRACT(YEAR FROM fecha) = ?", params[:year].to_i)
    end

    if params[:month].present?
      @buys = @buys.where("EXTRACT(MONTH FROM fecha) = ?", params[:month].to_i)
    end

    if params[:day].present?
      @buys = @buys.where("EXTRACT(DAY FROM fecha) = ?", params[:day].to_i)
    end

    # Si no hay resultados, mostrar mensaje y cargar todas
    if @buys.empty?
      flash.now[:alert] = "No se encontraron compras con esos filtros."
      @buys = Buy.includes(:payment, :user).order(fecha: :desc)
    end
    
    # Calcular estadísticas
    hoy = Time.zone.today
    semana = (hoy.beginning_of_week..hoy.end_of_week)
    mes = (hoy.beginning_of_month..hoy.end_of_month)
    anio = (hoy.beginning_of_year..hoy.end_of_year)
    
    @ventas_hoy = Buy.where(fecha: hoy.all_day).count
    @ventas_semana = Buy.where(fecha: semana).count
    @ventas_mes = Buy.where(fecha: mes).count
    @ventas_anio = Buy.where(fecha: anio).count
    @ventas_total = Buy.count
  end

  # GET /buys/1 or /buys/1.json
  def show
  end

  # GET /buys/new
  def new
    @buy = Buy.new
  end

  # GET /buys/1/edit
  def edit
  end

  # POST /buys or /buys.json
  def create
  venta_fisica = params[:buy][:tipo] == "presencial"

  @buy = Buy.new(
    tipo: venta_fisica ? "fisica" : "online",
    fecha: Time.current,
    metodo_pago: venta_fisica ? "Efectivo" : "Wompi"
  )

  if venta_fisica
    # Datos de venta física
    @buy.nombre_cliente    = params[:buy][:client_name]
    @buy.documento_cliente = params[:buy][:client_email]

    @buy.user_id     = nil
    @buy.payment_id  = nil

  else
    # Venta Online
    @buy.user       = current_user
    @buy.payment_id = params[:buy][:payment_id]
  end

  # --- Procesar productos ---
  productos_param = params[:venta][:products]
  total_compra = 0

  if productos_param.present?
    productos_param.each do |id, data|
      next unless data["select"] == "on"

      product   = Product.find(id)
      cantidad  = data["cantidad"].to_i
      subtotal  = product.precio * cantidad
      total_compra += subtotal

      # Items de compra
      @buy.purchasedetails.build(
        product: product,
        cantidad: cantidad,
preciounidad: product.precio
      )

      # Reducir stock
      product.update(stock: product.stock - cantidad)
    end
  end

  @buy.total = total_compra

  if @buy.save
    redirect_to buys_path, notice: "Su compra fue realizada correctamente"
  else
    render :new
  end
end

      
  

  # PATCH/PUT /buys/1 or /buys/1.json
  def update
    if @buy.update(buy_params)
      redirect_to @buy, notice: "Compra actualizada."
    else
      render :edit
    end
  end

  # DELETE /buys/1 or /buys/1.json
  def destroy
    @buy.destroy
    redirect_to buys_url, notice: "Compra eliminada."
  end

  def purchasedetails
    @purchasedetails = Purchasedetail.where(buy_id: params[:buy_id])
  end

  def productos
    @buy = Buy.find(params[:id])
    
    if @buy.purchasedetails.empty?
      render json: []
      return
    end
    
    productos = @buy.purchasedetails.includes(:product).map do |detail|
      {
        nombre: detail.product&.nombre || "Producto desconocido",
        cantidad: detail.cantidad || 0,
        precio_unitario: ActionController::Base.helpers.number_to_currency(detail.preciounidad || 0, unit: "COP ", separator: ",", delimiter: ".", precision: 2),
        subtotal: ActionController::Base.helpers.number_to_currency((detail.cantidad || 0) * (detail.preciounidad || 0), unit: "COP ", separator: ",", delimiter: ".", precision: 2),
        imagen: detail.product&.images&.attached? ? url_for(detail.product.images.first) : nil
      }
    end
    
    render json: productos
  rescue => e
    Rails.logger.error("Error en buys#productos: #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end

  def physical_sale
  ActiveRecord::Base.transaction do
    buy = Buy.create!(
      tipo: "Física",
      fecha: Time.current,
      method: "Efectivo",
      cliente_nombre: params[:cliente_nombre],
      cliente_email: params[:cliente_email],
      total: 0
    )

    params[:products].each do |p|
      product = Product.find(p[:id])
      cantidad = p[:cantidad].to_i

      Purchasedetail.create!(
        buy_id: buy.id,
        product_id: product.id,
        cantidad: cantidad,
        preciounidad: product.precio
      )

      product.update!(stock: product.stock - cantidad)

      buy.total += product.precio * cantidad
    end

    buy.save!
  end

  redirect_to dashboard_ventas_path, notice: "Venta registrada correctamente ✅"
end


  private

    # Use callbacks to share common setup or constraints between actions.
    def set_buy
      @buy = Buy.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def buy_params
      params.require(:buy).permit(
        :user_id, 
        :fecha, 
        :client_name,
        :client_email,                           
        :tipo,        
          
        :total, :payment_id)
    end
end
