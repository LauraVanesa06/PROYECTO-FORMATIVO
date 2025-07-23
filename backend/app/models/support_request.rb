class SupportRequest < ApplicationRecord
    def create
        @support_request = SupportRequest.new(support_request_params)

        if @support_request.save
            ContactarTecnicoMailer.notify_technician(@support_request).deliver_now
            flash[:notice] = "Tu mensaje fue enviado exitosamente."
            redirect_to dashboard_ayuda_path
        else
        flash[:alert] = "Hubo un error al enviar el mensaje."
        render :new
    end
end

private

    def support_request_params
    params.require(:support_request).permit(:user_name, :user_email, :description)
    end
end
