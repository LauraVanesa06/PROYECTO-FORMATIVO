class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]
  layout false

  # GET /customers or /customers.json
  def index
    @customers = Customer.all
    @customer = nil
    @purchasedetails = []
    @buys = Buy.all

    if params[:documento].present?
      doc = params[:documento].to_i
      @customers = @customers.where(documento: doc)
    end

    if params[:year].present? || params[:month].present? || params[:day].present?
      conditions = []
      values = []

      if params[:year].present?
        conditions << "strftime('%Y', buys.fecha) = ?"
        values << params[:year]
      end

      if params[:month].present?
        conditions << "strftime('%m', buys.fecha) = ?"
        values << params[:month].rjust(2, '0')
      end

      if params[:day].present?
        conditions << "strftime('%d', buys.fecha) = ?"
        values << params[:day].rjust(2, '0')
      end

      @buys = @buys.where(conditions.join(" AND "), *values)
    end

    buy_ids = @buys.pluck(:id)

    @customers = @customers.left_outer_joins(:buys).distinct.includes(:buys)

    if params[:customer_id].present?
      @customer = Customer.find_by(id: params[:customer_id])
      @purchasedetails = @customer&.purchasedetails&.includes(:product, buy: :customer) || []

    elsif params[:id].blank? && params[:name].blank?
      @purchasedetails = Purchasedetail.includes(:product, buy: :customer).all

    elsif @customers.size == 1
      @customer = @customers.first
      @purchasedetails = @customer.purchasedetails.includes(:product, buy: :customer)

      @purchasedetails = @customer&.purchasedetails&.includes(:product, buy: :customer) || []
      @purchasedetails = @purchasedetails.where(buy_id: buy_ids) if buy_ids.present?

    elsif params[:id].blank? && params[:name].blank? && params[:documento].blank?
      @purchasedetails = Purchasedetail.includes(:product, buy: :customer)
      @purchasedetails = @purchasedetails.where(buy_id: buy_ids) if buy_ids.present?

    elsif @customers.size == 1
      @customer = @customers.first
      @purchasedetails = @customer.purchasedetails.includes(:product, buy: :customer)
      @purchasedetails = @purchasedetails.where(buy_id: buy_ids) if buy_ids.present?

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
