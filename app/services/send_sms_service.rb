# frozen_string_literal: true

class SendSmsService
  attr_reader :sms_sent

  def initialize(mobile_number, message, is_admin, attendance_id={})
    @mobile_number = mobile_number
    @attendance_id = attendance_id
    @message = message
    @is_admin = is_admin
  end

  def call
    perform &&
    sms_sent?
    update_attendance unless admin?
  end

  def perform
    @response = Net::HTTP.post_form(
      URI.parse(Figaro.env.TEXT_LOCAL_URL),
      apiKey:      Figaro.env.MSG_API_KEY,
      sender:      "TXTLCL",
      message:     @message.squish,
      numbers:     @mobile_number,
      receipt_url: ""
    )
  end

  def update_attendance
    attendance.update_column(:sms_sent, sms_sent)
  end

  def sms_sent?
    @sms_sent = JSON.parse(@response.body)["status"] == "success"
  end

  private

  def attendance
    return unless @attendance_id.present?

    Attendance.find(@attendance_id)
  end

  def admin?
    @is_admin
  end
end
