# frozen_string_literal: true

class Usuarios::RegistrationsController < Devise::RegistrationsController
  layout :resolve_layout

  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  private

  def resolve_layout
    # Si viene del fetch (AJAX sidebar), no usar layout
    if request.headers["X-Requested-Sidebar"] == "true"
      false
    else
      "application"
    end
  end

  # Permitir el parámetro name en el registro
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # Permitir el parámetro name en la actualización
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
