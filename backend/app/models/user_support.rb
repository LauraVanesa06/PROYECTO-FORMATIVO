class UserSupport < ApplicationRecord
    def create
        @user_support = UserSupport.new(user_support_params)

        if @user_support.save
            ContactarAdministradorMailer.notify_technician(@user_support).deliver_now
            flash[:notice] = "Tu mensaje fue enviado exitosamente."
            redirect_to home_contacto_path
            
        else
        flash[:alert] = "Hubo un error al enviar el mensaje."
        render :new
    end
end

private

    def user_support_params
    params.require(:user_support).permit(:user_name, :user_apellido, :user_email, :description)
    end
end
