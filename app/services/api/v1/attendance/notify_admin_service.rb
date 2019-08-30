# frozen_string_literal: true

module Api
  module V1
    module Attendance
      class NotifyAdminService
        def initialize(school_id, date)
          @school_id = school_id
          @date = date
        end

        def call
          @attendances = ::Attendance.includes(:student).where(sms_sent: [false, nil], date: @date, school_id: @school_id)
          send_sms(admin, message_to_admin)
        end

        private

        def defaulters
          @defaulters ||= @attendances.each_with_object({}) {|c, h| (h[c.standard_id] ||= []).push(c.student.roll_no) }
        end

        def admin
          @admin = School.find(@school_id).admin
        end

        def message_to_admin
          message = I18n.translate("sms.notify_admin_part_1")
          defaulters.each do |standard_id, roll_nos|
            message << I18n.translate("sms.notify_admin_part_2", standard: standard_with_section(standard_id), roll_nos: roll_nos.sort.join(", "))
          end
          message
        end

        def standard_with_section(standard_id)
          standard = Standard.find(standard_id)
          standard.standard + " - " + standard.section
        end

        def send_sms(admin, message)
          return unless defaulters.present?
          
          SendSmsWorker.perform_async(admin.mobile_number, message, true, {receiver_id: admin.id, receiver_type: "Admin"})
        end
      end
    end
  end
end
