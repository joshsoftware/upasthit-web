# frozen_string_literal: true

class NotifyParentJob < ApplicationJob
  queue_as :default

  def perform(absent_student_attendance_ids)
    serv = Api::V1::Attendance::NotifyParentsService.new(absent_student_attendance_ids)
    return true if serv.call

    Rails.logger.error("NotifyParentsService: Failed #{serv.formatted_errors}")
  end
end
