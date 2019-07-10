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
          @defaulters = []
          data = attendances.where(sms_sent: [false, nil]).map do |attendance|
            {
              roll_no:                 attendance.student.roll_no,
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
            response = send_sms(student_data[:guardian_mobile_number], message_to_parents)
            response == "success" ? sms_sent_success : sms_sent_to_alternate_number
          end
          notify_admin
        end

        attr_reader :student_data

        private

        def attendances
          @attendances ||= ::Attendance.includes(:student).where(id: @absentee_attendance_ids)
        end

        def message_to_parents
          I18n.locale = preferred_language.to_sym
          name = ("name_" + preferred_language.underscore).to_sym
          "#{student_data[name]}#{I18n.translate('sms.absent')}\n"
        end

        def message_to_admin
          roll_nos = @defaulters.pluck(:roll_no).sort.join(", ")
          standard_with_section = attendance.standard.standard + "-" + attendance.standard.section
          I18n.translate("sms.notify_admin", roll_nos: roll_nos.to_s, standard: standard_with_section.to_s)
        end

        def preferred_language
          student_data[:preferred_language]
        end

        def attendance
          @attendance ||= ::Attendance.includes(:standard).find(student_data[:attendance_id])
        end

        def sms_sent_success
          attendance.update_column(:sms_sent, true)
        end

        def sms_sent_to_alternate_number
          response = send_sms(student_data[:alternate_mobile_number], message_to_parents)
          response == "success" ? sms_sent_success : store_failed_message_data
        end

        def store_failed_message_data
          @defaulters.push(student_data)
        end

        def notify_admin
          attendance.update_column(:sms_sent, false)
          @admin ||= attendance.school.staffs.select(&:admin?).first
          send_sms(@admin[:mobile_number], message_to_admin)
        end

        def send_sms(mobile_number, message)
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
