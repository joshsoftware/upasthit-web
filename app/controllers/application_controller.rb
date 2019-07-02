class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_locale

  private

  def after_sign_out_path_for(resource_or_scope)
    staff_session_path
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def current_school
    @current_school ||= School.first
  end
end
