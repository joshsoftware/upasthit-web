# frozen_string_literal: true

class SendSmsOnParentPrimaryNumberWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1
  # sidekiq_retries_exhausted do |msg|
  #   attendance_id = msg["args"].first
  #   message = msg["args"].second
  #   send_sms_on_alternate_number(attendance_id, message)
  # end

  def perform(attendance_id, message)
    attendance = Attendance.find(attendance_id)
    student = Student.find(attendance.student_id)
    message = message
    attendance_id = attendance_id
    mobile_number = student.guardian_mobile_no
    SendSmsWorker.new.perform(mobile_number, message, false, {receiver_id: student.id, receiver_type: "Parent", number_type: "primary_no"}, attendance_id)
  end

  def self.send_sms_on_alternate_number(attendance_id, message)
    SendSmsOnParentAlternateNumberWorker.perform_async(attendance_id, message)
  end
end
