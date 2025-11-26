class ProfileController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Perfil actualizado exitosamente'
    else
      render :edit, alert: 'Error al actualizar el perfil'
    end
  end

  def change_password
    @user = current_user
  end

  def update_password
    @user = current_user

    # Validar contraseña actual
    unless @user.valid_password?(params[:current_password])
      redirect_to change_password_profile_path, alert: 'La contraseña actual es incorrecta'
      return
    end

    # Validar nueva contraseña
    new_password = params[:new_password]
    password_confirmation = params[:password_confirmation]

    if new_password != password_confirmation
      redirect_to change_password_profile_path, alert: 'Las contraseñas no coinciden'
      return
    end

    # Validar requisitos de contraseña
    unless valid_password_format?(new_password)
      redirect_to change_password_profile_path, alert: 'La contraseña debe tener al menos 6 caracteres, una mayúscula, una minúscula y un número'
      return
    end

    # Actualizar contraseña
    if @user.update(password: new_password, password_confirmation: password_confirmation)
      bypass_sign_in(@user) # Mantener sesión activa
      redirect_to profile_path, notice: 'Contraseña actualizada exitosamente'
    else
      redirect_to change_password_profile_path, alert: 'Error al actualizar la contraseña'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end

  def valid_password_format?(password)
    password.length >= 6 &&
    password =~ /[A-Z]/ &&
    password =~ /[a-z]/ &&
    password =~ /[0-9]/
  end
end
