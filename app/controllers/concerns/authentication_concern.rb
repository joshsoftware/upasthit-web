# frozen_string_literal: true

module AuthenticationConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_staff, except: [:sms_callback, :sms_callback_pinnacle]
  end

  def pin_mob_from_header
    [request.headers[Figaro.env.X_USER_MOB_NUM], request.headers[Figaro.env.X_USER_PIN] ]
  end

  def render_unauthorized
    render json: {
      errors: [@error]
    }, status: :unauthorized
  end

  private

  def authenticate_staff
    mobile_number, pin = pin_mob_from_header
    verify_staff(mobile_number, pin)
  end

  def verify_staff(mobile_number, pin)
    staff = Staff.find_by(mobile_number: mobile_number, pin: pin)
    (@error = I18n.t("staff.invalid_login")) && render_unauthorized unless staff
  end
end
