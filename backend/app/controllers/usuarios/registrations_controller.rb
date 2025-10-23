# frozen_string_literal: true

class Usuarios::RegistrationsController < Devise::RegistrationsController
  layout :resolve_layout

  private

  def resolve_layout
    # Si viene del fetch (AJAX sidebar), no usar layout
    if request.headers["X-Requested-Sidebar"] == "true"
      false
    else
      "application"
    end
  end
end
