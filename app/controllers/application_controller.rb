# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pagy::Backend
  protect_from_forgery with: :null_session
  before_action :set_locale

  private

  def after_sign_out_path_for(_resource_or_scope)
    staff_session_path
  end

  def set_locale
    I18n.locale = extract_locale || I18n.default_locale
  end

  def default_url_options(options={})
    {locale: I18n.locale}.merge options
  end

  def extract_locale
    parsed_locale = params[:locale]
    I18n.available_locales.map(&:to_s).include?(parsed_locale) ? parsed_locale : nil
  end

  def current_school
    @current_school ||= School.first
  end

  def current_ability
    @current_ability ||= Ability.new(current_staff)
  end

  def after_sign_in_path_for(_resource)
    if current_staff.sign_in_count == 1
      edit_staff_password_path
    else
      root_path
    end
  end
end
