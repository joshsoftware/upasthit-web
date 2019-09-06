# frozen_string_literal: true

class SendSmsOnParentAlternateNumberWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(attendance_id, message)
    student_id = Attendance.find_by(id: attendance_id).student_id
    student = Student.find_by(id: student_id)
    mobile_number = student.guardian_alternate_mobile_no
    SendSmsWorker.new.perform(
      mobile_number,
      message,
      false,
      {receiver_id: student.id, receiver_type: "Parent", number_type: "alternate_no"},
      attendance_id
    )
  end
end
