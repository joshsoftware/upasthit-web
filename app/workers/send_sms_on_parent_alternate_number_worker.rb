# frozen_string_literal: true

class SendSmsOnParentAlternateNumberWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(attendance_id, message)
    attendance = Attendance.find(attendance_id)
    student = Student.find(attendance.student_id)
    mobile_number = student.guardian_alternate_mobile_no
    SendSmsWorker.new.perform(mobile_number, message, false, attendance_id)
  end
end
