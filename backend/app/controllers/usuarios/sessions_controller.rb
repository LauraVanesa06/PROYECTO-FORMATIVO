# frozen_string_literal: true

class Usuarios::SessionsController < Devise::SessionsController
  layout :resolve_layout

  def create
    self.resource = warden.authenticate(auth_options)
    if resource
      if request.headers["X-Requested-Sidebar"] == "true"
        sign_in(resource_name, resource)
        render json: { success: true, redirect_url: after_sign_in_path_for(resource) }
      else
        set_flash_message!(:notice, :signed_in)
        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_in_path_for(resource)
      end
    else
      flash.now[:alert] = "Correo o contraseña inválidos. Por favor, intenta de nuevo."
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      if request.headers["X-Requested-Sidebar"] == "true"
        respond_with_navigational(resource) { render :new, status: :unprocessable_entity, layout: false }
      else
        respond_with_navigational(resource) { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def resolve_layout
    # 👇 Detecta la cabecera que mandamos desde JS
    if request.headers["X-Requested-Sidebar"] == "true"
      false
    else
      "application"
    end
  end
end
