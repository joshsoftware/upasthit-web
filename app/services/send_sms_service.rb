# frozen_string_literal: true

require "net/http"
class SendSmsService
  attr_reader :sms_sent

  def initialize(mobile_number, message, is_admin, receiver_info={}, attendance_id={})
    @mobile_number = mobile_number
    @attendance_id = attendance_id
    @message = message
    @is_admin = is_admin
    @receiver_info = receiver_info
  end

  def call
    perform
  end

  def perform
    @response = Net::HTTP.post_form(
                                     URI.parse(Figaro.env.SMS_URL),
                                     username:      Figaro.env.SMS_USERNAME,
                                     pass:          Figaro.env.SMS_PASSWORD,
                                     senderid:      Figaro.env.SMS_SENDERID,
                                     dest_mobileno: @mobile_number,
                                     message:       @message.squish,
                                     response:      Figaro.env.SMS_RESPONSE,
                                     Msgtype:       Figaro.env.SMS_MSGTYPE
                                    )
    SmsLog.generate(sms_log_hash)
  end

  def sms_log_hash
    @receiver_info = @receiver_info.map {|k, v| [k.to_sym, v] }.to_h
    {
      receiver_mobile: @mobile_number,
      content:         @message.squish,
      message_token:   @response.body,
      receiver_id:     @receiver_info[:receiver_id],
      sender_type:     "Server",
      receiver_type:   @receiver_info[:receiver_type],
      number_type:     @receiver_info[:number_type],
      other_info:      {attendance_id: @attendance_id}
    }
  end

  def update_attendance
    attendance.update_column(:sms_sent, sms_sent)
  end

  def sms_sent?
    @sms_sent = @response.code == "200"
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
