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



