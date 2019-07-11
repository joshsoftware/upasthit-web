# frozen_string_literal: true

class SendSmsJob < ApplicationJob
  queue_as :default

  def perform(absent_student_attendance_ids)
    serv = Api::V1::Attendance::SendSmsService.call(absent_student_attendance_ids)
    return true if serv

    Rails.logger.error("SendSmsService: Failed #{serv.formatted_errors}")
  end
end
