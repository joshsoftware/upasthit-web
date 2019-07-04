# frozen_string_literal: true

module Api
  module Staffs
    class SessionsController < ::BaseController
      skip_after_action :set_auth_header, only: [:destroy]
      skip_before_action :authenticate_resource_from_token!, only: %i[create sync]
      before_action :validate_mobile_number, only: :sync

      def create
        staff = Staff.find_by(mobile_number: params[:session][:mobile_number])
        if staff&.valid_password?(params[:session][:password])
          sign_in staff, store: false
          render_success(data: {mobile_number: staff.mobile_number, name: staff.name}, message: I18n.t("staff.signed_in"), status: :created)
        else
          render_error(message: I18n.t("staff.invalid_login"), status: :unauthorized)
        end
      end

      def destroy
        current_staff.set_auth_token

        if sign_out current_staff
          render_success(data: {username: nil}, message: I18n.t("staff.signed_out"))
        else
          render_error(message: I18n.t("error.unauthorized"), status: :unauthorized)
        end
      end

      def sync
        service = SyncService.new(staff_params)
        if service.sync
          render json: service.result
        else
          render json: {errors: service.errors.messages}, status: 400
        end
      end

      private

      def validate_mobile_number
        render json: {message: I18n.t("error.absent_mobile_no")}, status: 422 unless staff_params[:mobile_number].present?
      end

      def staff_params
        params.permit(:id, :mobile_number, :pin)
      end
    end
  end
end
