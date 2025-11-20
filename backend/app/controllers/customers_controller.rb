class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]
  layout false

  # GET /customers or /customers.json
  def index
  # base - cambiar a trabajar con User en lugar de Customer
  @users = User.left_outer_joins(:buys).distinct.includes(:buys)
  @customer = nil
  @purchasedetails = []
  @buys = Buy.all

  # filtro por email (ya que User no tiene documento)
  @users = @users.where("users.email LIKE ?", "%#{params[:documento]}%") if params[:documento].present?

  # arma condiciones de fecha (día/mes/año) sobre buys.fecha
  conditions, values = [], []
  { day: '%d', month: '%m', year: '%Y' }.each do |p, f|
    next unless params[p].present?
    values << (p == :year ? params[p] : params[p].rjust(2, '0'))
    conditions << "strftime('#{f}', buys.fecha) = ?"
  end

  # si hay condiciones, filtra both: buys y users
  if conditions.any?
    where_sql = conditions.join(' AND ')
    @buys = Buy.where(where_sql, *values)
    @users = @users.where(where_sql, *values)
  end

  buy_ids = @buys.pluck(:id)

  # --- lógica para purchasedetails en el ASIDE ---
  if @users.empty? # si el filtro no trajo usuarios
    flash.now[:alert] = "¡No se encontraron usuarios con esos filtros!"
    @users = User.all
    @purchasedetails = Purchasedetail.includes(:product, buy: :user) # todas las compras
  else
    # purchasedetails normal, según selección o resultados
    if params[:documento].present?
      @user = User.find_by(email: params[:documento])
      @purchasedetails = @user ? @user.buys.includes(purchasedetails: [:product]).map(&:purchasedetails).flatten.uniq : []
    elsif @users.size == 1
      @user = @users.first
      @purchasedetails = @user.buys.includes(purchasedetails: [:product]).map(&:purchasedetails).flatten.uniq
    else
      @purchasedetails = Purchasedetail.includes(:product, buy: :user)
      @purchasedetails = @purchasedetails.where(buy_id: buy_ids) if buy_ids.present?
    end
  end

  @filter_result_empty = @users.blank?
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
    @user = User.find(params[:id])
    @buys = @user.buys
  end

  def purchasedetails
  @user = User.find(params[:id])
  @purchasedetails = @user.buys.includes(purchasedetails: [:product]).map(&:purchasedetails).flatten.uniq
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
