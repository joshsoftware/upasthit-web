# frozen_string_literal: true

module Api
  module V1
    module Attendance
      class NotifyParentsService
        attr_reader :student_data

        def initialize(absentee_attendance_ids)
          @absentee_attendance_ids = absentee_attendance_ids
        end

        def call
          @defaulters = []
          data = attendances.where(sms_sent: [false, nil]).map do |attendance|
            {
              roll_no:            attendance.student.roll_no,
              student_id:         attendance.student.id,
              first_name_en:      attendance.student.first_name_en,
              first_name_mr_in:   attendance.student.first_name_mr_in,
              last_name_en:       attendance.student.last_name_en,
              last_name_mr_in:    attendance.student.last_name_mr_in,
              attendance_id:      attendance.id,
              preferred_language: attendance.student.preferred_language
            }
          end
          data.each do |student_data|
            @student_data = student_data
            send_sms(message_to_parents)
          end
        end

        private

        def attendances
          @attendances ||= ::Attendance.includes(:student).where(id: @absentee_attendance_ids)
        end

        def message_to_parents
          I18n.locale = preferred_language.to_sym
          first_name = ("first_name_" + preferred_language.underscore).to_sym
          last_name = ("last_name_" + preferred_language.underscore).to_sym
          "#{student_data[first_name]} #{student_data[last_name]}#{I18n.translate('sms.absent')}\n"
        end

        def preferred_language
          student_data[:preferred_language]
        end

        def attendance
          @attendance = ::Attendance.includes(:standard).find(student_data[:attendance_id])
        end

        def school_id
          @school_id ||= attendance.school_id
        end

        def send_sms(message)
          return if attendance.sms_sent?
          SendSmsOnParentPrimaryNumberWorker.perform_async(attendance.id, message)
        end
      end
    end
  end
end
