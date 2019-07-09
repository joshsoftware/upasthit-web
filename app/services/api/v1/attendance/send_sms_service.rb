# frozen_string_literal: true

module Api
  module V1
    module Attendance
      class SendSmsService
        def self.call(absentee_attendance_ids)
          new(absentee_attendance_ids)
        end

        def initialize(absentee_attendance_ids)
          @absentee_attendance_ids = absentee_attendance_ids

          data = attendances.where(sms_sent: [false, nil]).map do |attendance|
            {
              guardian_mobile_number:  attendance.student.guardian_mobile_no,
              alternate_mobile_number: attendance.student.guardian_alternate_mobile_no,
              name_en:                 attendance.student.name_en,
              name_mr_in:              attendance.student.name_mr_in,
              attendance_id:           attendance.id,
              preferred_language:      attendance.student.preferred_language
            }
          end
          data.each do |student_data|
            @student_data = student_data
            response = send_sms(student_data[:guardian_mobile_number])
            response == "success" ? sms_sent_success : sms_sent_to_alternate_number
          end
        end

        attr_reader :student_data

        private

        def attendances
          @attendances ||= ::Attendance.includes(:student).where(id: @absentee_attendance_ids)
        end

        def message
          I18n.locale = preferred_language.to_sym
          name = ("name_" + preferred_language.underscore).to_sym
          "#{student_data[name]}#{I18n.translate('sms.absent')}\n"
        end

        def preferred_language
          student_data[:preferred_language]
        end

        def sms_sent_success
          ::Attendance.find(student_data[:attendance_id]).update_column(:sms_sent, true)
        end

        def sms_sent_to_alternate_number
          response = send_sms(student_data[:alternate_mobile_number])
          response == "success" ? sms_sent_success : notify_admin
        end

        def notify_admin
          ::Attendance.find(student_data[:attendance_id]).update_column(:sms_sent, false)
          "********Notify to Admin*********"
        end

        def send_sms(mobile_number)
          response = Net::HTTP.post_form(
            URI.parse(Figaro.env.TEXT_LOCAL_URL),
            apiKey:      Figaro.env.MSG_API_KEY,
            sender:      "TXTLCL",
            message:     message.squish,
            numbers:     [mobile_number],
            receipt_url: ""
          )
          JSON.parse(response.body)["status"]
        end
      end
    end
  end
end
