class BaseController < ApiController
  include AuthenticationConcern
  rescue_from ActiveRecord::RecordNotFound, ActionController::RoutingError, with: :handle_api_exceptions

  def render_error(errors: {}, message: nil, status: :internal_server_error)
    render json: { errors: errors, message: message }, status: status
  end

  def render_success(data:, message: nil, status: :ok)
    render json: { data: data, message: message }, status: status
  end

  def handle_api_exceptions(exception)
    message = exception.message || I18n.t('error.internal_server')
    if exception.is_a?(ActiveRecord::RecordNotFound)
      render_error(message: message, status: :not_found)
    elsif exception.is_a?(ActionController::RoutingError)
      render_error(message: message, status: :not_found)
    end
  end
end