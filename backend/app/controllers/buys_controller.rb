class BuysController < ApplicationController
  before_action :set_buy, only: %i[ show edit update destroy ]
  layout false

  # GET /buys or /buys.json
  def index
    @buys = Buy.all.order(created_at: :desc).limit(100)
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
