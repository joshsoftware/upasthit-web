# frozen_string_literal: true

class SendSmsOnParentPrimaryNumberWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3
  sidekiq_retries_exhausted do |msg|
    student_id = msg["args"].first
    message = msg["args"].second
    attendance_id = msg["args"].third
    send_sms_on_alternate_number(student_id, message, attendance_id)
  end

  def perform(student_id, message, attendance_id)
    student = Student.find(student_id)
    message = message
    attendance_id = attendance_id
    mobile_number = student.guardian_mobile_no
    SendSmsWorker.new.perform(mobile_number, message, false, attendance_id)
  end

  def self.send_sms_on_alternate_number(student_id, message, attendance_id)
    student = Student.find(student_id)
    mobile_number = student.guardian_alternate_mobile_no
    SendSmsOnParentAlternateNumberWorker.perform_async(mobile_number, message, attendance_id)
  end
end
