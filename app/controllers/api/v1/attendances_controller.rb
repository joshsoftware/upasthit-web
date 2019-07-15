# frozen_string_literal: true

module Api
  module V1
    class AttendancesController < V1::BaseController
      before_action :validate_date, only: :sync

      def sync
        service = Attendance::SyncService.new(attendance_params)
        if service.sync
          render json: service.result
        else
          render json: {errors: service.errors.messages}, status: 400
        end
      end

      private

      def validate_date
        render json: {message: I18n.t("error.absent_date")}, status: 422 unless attendance_params[:date].present?
      end

      def attendance_params
        params.permit(:date, :school_id)
      end
    end
  end
end
