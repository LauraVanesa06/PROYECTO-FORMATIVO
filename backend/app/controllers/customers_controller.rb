class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]
  layout false

  # GET /customers or /customers.json
  def index
  # base
  @customers = Customer.left_outer_joins(:buys).distinct.includes(:buys)
  @customer = nil
  @purchasedetails = []
  @buys = Buy.all

  # filtro por documento (solo afecta la lista de clientes)
  @customers = @customers.where("customers.documento LIKE ?", "%#{params[:documento]}%") if params[:documento].present?

  # arma condiciones de fecha (día/mes/año) sobre buys.fecha
  conditions, values = [], []
  { day: '%d', month: '%m', year: '%Y' }.each do |p, f|
    next unless params[p].present?
    values << (p == :year ? params[p] : params[p].rjust(2, '0'))
    conditions << "strftime('#{f}', buys.fecha) = ?"
  end

  # si hay condiciones, filtra both: buys y customers (clientes que tienen esas buys)
  if conditions.any?
    where_sql = conditions.join(' AND ')
    @buys = Buy.where(where_sql, *values)
    @customers = @customers.where(where_sql, *values)
  end

  buy_ids = @buys.pluck(:id)

  # purchasedetails según la selección o resultados
  if params[:documento].present?
    @customer = Customer.find_by(documento: params[:documento])
    @purchasedetails = @customer ? @customer.purchasedetails.includes(:product, buy: :customer).where(buy_id: buy_ids) : []
  elsif @customers.size == 1
    @customer = @customers.first
    @purchasedetails = @customer.purchasedetails.includes(:product, buy: :customer).where(buy_id: buy_ids)
  else
    @purchasedetails = Purchasedetail.includes(:product, buy: :customer)
    @purchasedetails = @purchasedetails.where(buy_id: buy_ids) if buy_ids.present?
  end

  # mensaje si no hay clientes tras aplicar filtros
  if @customers.empty?
    flash.now[:alert] = "¡No se encontraron clientes con esos filtros!"
    @customers = Customer.all
  end

  @filter_result_empty = @customers.blank?
end


  # GET /customers/1 or /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: "Customer was successfully updated." }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy!

    respond_to do |format|
      format.html { redirect_to customers_path, status: :see_other, notice: "Customer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def buys
    @customer = Customer.find(params[:id])
    @buys = @customer.buys
  end

  def purchasedetails
  @customer = Customer.find(params[:id])
  @purchasedetails = @customer.purchasedetails
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.expect(customer: [ :nombre, :telefono ])
    end
end
