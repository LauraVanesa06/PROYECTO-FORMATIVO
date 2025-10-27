class Usuarios::PasswordsController < Devise::PasswordsController
  layout 'custom_login'

  # 👇 Este método se ejecuta antes de renderizar la vista
  before_action :disable_layout_for_sidebar

  private

  def disable_layout_for_sidebar
    if request.headers["X-Requested-Sidebar"].present?
      self.class.layout false
    end
  end
end
