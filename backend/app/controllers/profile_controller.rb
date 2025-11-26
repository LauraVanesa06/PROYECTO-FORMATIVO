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

  private

  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end
end
