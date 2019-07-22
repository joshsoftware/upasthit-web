# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  layout "login"

  before_action :configure_sign_in_params

  private

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[user_name password])
  end
end
