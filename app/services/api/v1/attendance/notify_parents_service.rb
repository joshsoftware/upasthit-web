# frozen_string_literal: true

module Api
  module V1
    module Attendance
      class NotifyParentsService
        def initialize(absentee_attendance_ids)
          @absentee_attendance_ids = absentee_attendance_ids
        end

        def call
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
            send_sms(student_data[:guardian_mobile_number], message_to_parents)
            send_sms(student_data[:guardian_alternate_mobile_no], message_to_parents)
          end
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

        def preferred_language
          student_data[:preferred_language]
        end

        def attendance
          @attendance ||= ::Attendance.includes(:standard).find(student_data[:attendance_id])
        end

        def school_id
          @school_id ||= attendance.school_id
        end

        def send_sms(mobile_number, message)
          return if attendance.sms_sent?

          SendSmsJob.perform_async(mobile_number, message, false, attendance.id)
        end
      end
    end
  end
end
