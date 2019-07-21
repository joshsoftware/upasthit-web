# frozen_string_literal: true

module Api
  module V1
    class AttendancesController < V1::BaseController
      before_action :validate_authorized_sender, :validate_message, only: :sms_callback
      before_action :validate_date_present, :validate_date_format, only: :sync

      def create
        if create_service(attendance_params).create
          render json: create_service.result
        else
          render json: {errors: create_service.errors.messages}, status: 400
        end
      end

      def sms_callback
        sms_callback_params = parse_message
        if create_service(sms_callback_params).create
          render json: create_service.result
        else
          render json: {errors: create_service.errors.messages}, status: 400
        end
      end

      def sync
        service = Attendance::SyncService.new(attendance_params)
        if service.sync
          render json: service.result
        else
          render json: {errors: service.errors.messages}, status: 400
        end
      end

      private

      def create_service(sms_callback_params={})
        @create_service ||= Api::V1::Attendance::CreateService.new(sms_callback_params)
      end

      def attendance_params
        params.permit(:standard, :school_code, :school_id, :date, :section, absent_roll_nos: [])
      end

      def validate_authorized_sender
        return true if params[:sender] == Figaro.env.AUTHORISED_SENDER

        render json: {message: I18n.t("error.not_trusted_sender")}, status: 422
      end

      def validate_message
        message = params[:comments]
        return true if message.match?(%r{^\d{1,2}\/\d{1,2}\/\d{4}\s\d*\s\d{1,2}(-\w)*(\s[\d\s\d]{1,2})*\z})

        render json: {message: I18n.t("sms.invalid_message")}, status: 422
      end

      def parse_message
        data = params[:comments].split(/[',', ' ']/).map {|k| k.gsub("\n", "") }
        {
          date:            data[0],
          school_code:     data[1],
          standard:        data[2].split("-").first,
          section:         data[2].split("-").second,
          absent_roll_nos: data[3..]
        }
      end

      def validate_date_present
        render json: {message: I18n.t("error.absent_date")}, status: 422 unless attendance_params[:date].present?
      end

      def validate_date_format
        render json: {message: I18n.t("error.date_invalid_format")}, status: 422 unless attendance_params[:date].match? %r{(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/(19|20)\d\d}
      end
    end
  end
end
