module AuthenticationConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_resource_from_token!
    after_action :set_auth_header, if: -> { current_staff.present? }
  end

  attr_reader :resource, :payload

  private

  def authenticate_resource_from_token!
    @jwt_token, @auth_token = get_jwt_and_auth_token_from_header
    return unless @jwt_token && @auth_token

    @payload  = JWT.decode(@jwt_token, @auth_token).first
    @resource = payload['resource_type'].constantize_with_care(['Staff']).where(
      id: payload['resource_id']
    ).first
    authenticate_and_login
  rescue
    @error = I18n.t('user.invalid_login') and render_unauthorized
  end

  def set_auth_header
    response.headers[Figaro.env.X_USER_AUTH_TOKEN]  = current_staff.auth_token
    response.headers[Figaro.env.X_USER_JWT_TOKEN]   = current_staff.jwt_token
  end

  def get_jwt_and_auth_token_from_header
    jwt_token = request.headers[Figaro.env.X_USER_JWT_TOKEN]
    auth_token = request.headers[Figaro.env.X_USER_AUTH_TOKEN]

    unless jwt_token && auth_token
      @error = I18n.t('user.access_denied') and render_unauthorized
    end
    [jwt_token, auth_token]
  end

  def authenticate_and_login
    if resource && Devise.secure_compare(resource.auth_token, @auth_token)
      request.env['devise.skip_trackable'] = true
      sign_in resource, store: false
      current_staff.remember_me = true if payload['remember']
    else
      @error = I18n.t('staff.invalid_credentials') and render_unauthorized
    end
  end

  def render_unauthorized
    render json: {
      errors: [@error]
    }, status: :unauthorized
  end
end
