class HomeController < ApplicationController
  layout "public"
  skip_before_action :authenticate_user!

  def index
    @category = Category.all
    @productos = Product.limit(4) # Si quieres mostrar productos en la vista pública
  end

  def producto
    @categories = Category.includes(:products)
  end

  def contacto
  end

  def send_report
    @user_support = UserSupport.new(user_support_params)

    if @user_support.save
      ContactarAdministradorMailer.reporte_duda(@user_support).deliver_now
      ContactarAdministradorMailer.confirmar_user(@user_support).deliver_now

      flash[:notice] = "Tu mensaje fue enviado correctamente."
      redirect_to contactos_path(sent: true)
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
