# frozen_string_literal: true

class SendSmsJob
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(mobile_number, message, is_admin, attendance_id={})
    @response = Net::HTTP.post_form(
      URI.parse(Figaro.env.TEXT_LOCAL_URL),
      apiKey:      Figaro.env.MSG_API_KEY,
      sender:      "TXTLCL",
      message:     message.squish,
      numbers:     [mobile_number],
      receipt_url: ""
    )
    update_attendance(attendance_id) unless is_admin
  end

  def update_attendance(attendance_id)
    status = JSON.parse(@response.body)["status"]
    attendance = Attendance.find(attendance_id)
    sms_sent = (status == "success")
    attendance.update_column(:sms_sent, sms_sent)
  end
end
