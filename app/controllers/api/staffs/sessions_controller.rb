class Api::Staffs::SessionsController < ::BaseController
  skip_after_action :set_auth_header, only: [:destroy]
  skip_before_action :authenticate_resource_from_token!, only: [:create]

  def create
    staff = Staff.find_by(mobile_number: params[:session][:mobile_number])
    if staff && staff.valid_password?(params[:session][:password])
      sign_in staff, store: false
      render_success(data: { mobile_number: staff.mobile_number, name: staff.name }, message: I18n.t('staff.signed_in'), status: :created)
    else
      render_error(message: I18n.t('staff.invalid_login'), status: :unauthorized)
    end
  end

  def destroy
    current_staff.set_auth_token

    if sign_out current_staff
      render_success(data: { username: nil }, message: I18n.t('staff.signed_out'))
    else
      render_error(message: I18n.t('error.unauthorized'), status: :unauthorized)
    end
  end
end
