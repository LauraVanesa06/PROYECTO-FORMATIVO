class PurchasedetailsController < ApplicationController
  before_action :set_purchasedetail, only: %i[ show edit update destroy ]

  # GET /purchasedetails or /purchasedetails.json
  def index
    @purchasedetails = Purchasedetail.all
  end

  # GET /purchasedetails/1 or /purchasedetails/1.json
  def show
  end

  # GET /purchasedetails/new
  def new
    @purchasedetail = Purchasedetail.new
  end

  # GET /purchasedetails/1/edit
  def edit
  end

  # POST /purchasedetails or /purchasedetails.json
  def create
    @purchasedetail = Purchasedetail.new(purchasedetail_params)

    respond_to do |format|
      if @purchasedetail.save
        format.html { redirect_to @purchasedetail, notice: "Purchasedetail was successfully created." }
        format.json { render :show, status: :created, location: @purchasedetail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @purchasedetail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /purchasedetails/1 or /purchasedetails/1.json
  def update
    respond_to do |format|
      if @purchasedetail.update(purchasedetail_params)
        format.html { redirect_to @purchasedetail, notice: "Purchasedetail was successfully updated." }
        format.json { render :show, status: :ok, location: @purchasedetail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @purchasedetail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /purchasedetails/1 or /purchasedetails/1.json
  def destroy
    @purchasedetail.destroy!

    respond_to do |format|
      format.html { redirect_to purchasedetails_path, status: :see_other, notice: "Purchasedetail was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def products
    @purchasedetails = Purchasedetail.find(params[:id])
    @products = @purchasedetails.products
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchasedetail
      @purchasedetail = Purchasedetail.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def purchasedetail_params
      params.expect(purchasedetail: [ :buy_id, :supplier_id, :cantidad, :preciounidad ])
    end
end
