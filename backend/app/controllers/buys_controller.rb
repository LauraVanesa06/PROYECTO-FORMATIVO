class BuysController < ApplicationController
  before_action :set_buy, only: %i[ show edit update destroy ]
  layout false

  # GET /buys or /buys.json
  def index

    #Cargar todas las ventas con sus detalles y filtros
    @buys = Buy.includes(:payment, :customer).order(fecha: :desc)

    @purchasedetails = Purchasedetail.all
    @purchasedetails = Purchasedetail.joins("INNER JOIN buys ON buys.id = purchasedetails.buy_id")
    conditions = []
    values = []

    @customer = Customer.joins(:buys).distinct.where("nombre LIKE ?", "%#{params[:customer]}%") if params[:customer].present?
    @buys = @buys.where(customer_id: @customer.ids) if params[:customer].present?

    { year: '%Y', month: '%m', day: '%d' }.each do |param, format|
      next unless params[param].present?
      conditions << "strftime('#{format}', buys.fecha) = ?"
      values << params[param].rjust(2, '0')
    end

    query = Buy.joins(:customer)
    query = query.where(conditions.join(" AND "), *values) unless conditions.empty?

    @buys = query

      if @buys.empty?
        flash.now[:alert] = "No se encontraron compras con esos filtros."
        @buys = Buy.all
      end

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
    @buy = Buy.new(buy_params)
    if @buy.save
      redirect_to @buy, notice: "Compra creada."
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

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_buy
      @buy = Buy.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def buy_params
      params.require(:buy).permit(:customer_id, :fecha, :total, :payment_id)
    end
end
