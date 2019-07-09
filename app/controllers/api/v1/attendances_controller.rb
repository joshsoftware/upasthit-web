# frozen_string_literal: true

module Api
  module V1
    class AttendancesController < V1::BaseController
      def create
        service = Attendance::CreateService.new(attendance_params)
        if service.create
          render json: service.result
        else
          render json: {errors: service.errors.messages}, status: 400
        end
      end

      def sms_callback
        if params[:sender] == Figaro.env.AUTHORISED_SENDER
          # ["Date:", "27.04.2019", "Std:", "5", "Section:", "C", "Roll_no:", "1", "2", "3"]
          data = params[:comments].split(/[',', ' ']/).map {|k| k.gsub("\n", "") }
          date = Date.parse(data[1])
          standard = data[3].to_i
          section = data[5]
          absent_roll_nos = data.split("Roll_no:")[1]
          standard_id = Standard.find_by(standard: standard, section: section).id
          create_attendance(absent_roll_nos, standard_id, date)
        else
          render_error(message: I18n.t("error.not_trusted_sender"), status: :unprocessable_entity)
        end
      end

      private

      def attendance_params
        params.permit(:standard_id, :school_code, :date, :section, absent_roll_nos: [])
      end

      def create_attendance(roll_nos, standard_id, date)
        Attendance::Create.new(roll_nos, standard_id, date).call
      end
    end
  end
end
