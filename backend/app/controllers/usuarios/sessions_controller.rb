# frozen_string_literal: true

class Usuarios::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  def custom_login
    render :new
  end

  private

  def resolve_layout
    action_name == "custom_login" ? "login" : "application"
  end

 
  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
