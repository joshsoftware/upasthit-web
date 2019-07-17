# frozen_string_literal: true

module Api
  module V1
    class AttendancesController < BaseController
      before_action :validate_date_present, :validate_date_format, only: :sync

      def sync
        service = Attendance::SyncService.new(attendance_params)
        if service.sync
          render json: service.result
        else
          render json: {errors: service.errors.messages}, status: 400
        end
      end

      private

      def validate_date_present
        render json: {message: I18n.t("error.absent_date")}, status: 422 unless attendance_params[:date].present?
      end

      def validate_date_format
        render json: {message: I18n.t("error.date_invalid_format")}, status: 422 unless attendance_params[:date].match? %r{(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)\d\d}
      end

      def attendance_params
        params.permit(:date, :school_id)
      end
    end
  end
end
