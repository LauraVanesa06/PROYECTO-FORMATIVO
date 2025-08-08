class BuysController < ApplicationController
  before_action :set_buy, only: %i[ show edit update destroy ]
  layout false  


  # GET /buys or /buys.json
  def index
    @buys = Buy.all
    @purchasedetails = Purchasedetail.all
    @purchasedetails = Purchasedetail.joins("INNER JOIN buys ON buys.id = purchasedetails.buy_id")
    @cliente = Customer.joins(:buys).distinct

    if params[:customer].present? || params[:year].present? || params[:month].present? || params[:day].present?
      conditions = []
      values = []

      #@buys = @buys.where(customer_id: params[:customer_id]) if params[:customer_id].present?
      #@buys = @buys.where("customer_id LIKE ?", "%#{params[:customer_id]}%") if params[:customer_id].present?
      @cliente = Customer.joins(:buys).distinct.where("nombre LIKE ?", "%#{params[:customer]}%")
      @buys = @buys.where(customer_id: @cliente.ids)

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

    respond_to do |format|
      if @buy.save
        format.html { redirect_to @buy, notice: "Buy was successfully created." }
        format.json { render :show, status: :created, location: @buy }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @buy.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /buys/1 or /buys/1.json
  def update
    respond_to do |format|
      if @buy.update(buy_params)
        format.html { redirect_to @buy, notice: "Buy was successfully updated." }
        format.json { render :show, status: :ok, location: @buy }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @buy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buys/1 or /buys/1.json
  def destroy
    @buy.destroy!

    respond_to do |format|
      format.html { redirect_to buys_path, status: :see_other, notice: "Buy was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def purchasedetails
    @buy = Buy.find(params[:id])
    @purchasedetails = @buy.purchasedetails
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_buy
      @buy = Buy.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def buy_params
      params.expect(buy: [ :customer_id, :fecha ])
    end
end
