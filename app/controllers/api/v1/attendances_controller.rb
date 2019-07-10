# frozen_string_literal: true

module Api
  module V1
    class AttendancesController < V1::BaseController
      before_action :validate_message, only: :sms_callback

      def create
        if create_service(attendance_params).create
          render json: create_service.result
        else
          render json: {errors: create_service.errors.messages}, status: 400
        end
      end

      def sms_callback
        if params[:sender] == Figaro.env.AUTHORISED_SENDER
          sms_callback_params = parse_message
          if create_service(sms_callback_params).create
            render json: create_service.result
          else
            render json: {errors: create_service.errors.messages}, status: 400
          end
        else
          render_error(message: I18n.t("error.not_trusted_sender"), status: :unprocessable_entity)
        end
      end

      private

      def create_service(sms_callback_params={})
        @create_service ||= Attendance::CreateService.new(sms_callback_params)
      end

      def attendance_params
        params.permit(:standard, :school_code, :date, :section, absent_roll_nos: [])
      end

      def validate_message
        message = params[:comments]
        return true if message.match?(%r{^\d{1,2}/\d{1,2}/\d{4}\s\d*\s\d{1,2}(-\w)*(\s[\d\s\d])*\z})

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
    end
  end
end
