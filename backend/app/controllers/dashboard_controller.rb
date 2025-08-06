class DashboardController < ApplicationController
  layout false  
  def index
  end

  layout false

  before_action :authenticate_user!
  before_action :only_admins

  def only_admins
    redirect_to authenticated_root_path, alert: "No autorizado" unless current_user&.admin?
  end

  
  def ventas
    
  end

  def clientes
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

  def help
  end
  def send_report
    @support_request = SupportRequest.new(support_request_params)


    if @support_request.save
    ContactarTecnicoMailer.reporte_error(@support_request).deliver_now
      ContactarTecnicoMailer.confirm_user(@support_request).deliver_now

    flash[:notice] = "Tu mensaje fue enviado correctamente."
    redirect_to help_path(sent: true)
  else

    flash[:alert] = "Hubo un error al enviar el mensaje."
    render :new
  
  end
    
end
  
  private

  def supplier_params
    params.require(:supplier).permit(:nombre, :contacto)
  end

 
  def support_request_params
  params.require(:support_request).permit(:user_name, :user_email, :description)
  end

  
end



