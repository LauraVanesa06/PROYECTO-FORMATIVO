# frozen_string_literal: true

class Usuarios::SessionsController < Devise::SessionsController
  layout 'custom_login'

  # Sobrescribir create para manejar errores con flash
  def create
    self.resource = warden.authenticate(auth_options)

    if resource
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      flash.now[:alert] = "Correo o contraseña inválidos. Por favor, intenta de nuevo."
      self.resource = resource_class.new(sign_in_params)
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render :new, status: :unprocessable_entity }
    end
  end
end
