# frozen_string_literal: true

require "net/http"
class PollingJob
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform
    sms_logs = SmsLog.where(status: "sending")
    sms_logs.each do |sms_log|
      next if delivered?(sms_log) && !sms_log.other_info["attendance_id"].present?

      attendance = Attendance.find_by(id: sms_log.other_info.dig("attendance_id"))
      sms_log.number_type == "primary_no" && SendSmsOnParentAlternateNumberWorker.perform_async(attendance.id, sms_log.content)
    end
  end

  private

  def delivered?(sms_log)
    uri = URI("#{Figaro.env.SMS_RESPONSE_URL}Scheduleid=#{sms_log.message_token}")
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new uri
      response = http.request request
      if response.body.include?("DELIVRD")
        sms_log.update_column(:status, "delivered")
        return true
      else
        status = if response.body.include?("PENDING")
                   "pending"
                 else
                   "failed"
                 end
        sms_log.update_column(:status, status)
        Attendance.find_by(id: sms_log.other_info["attendance_id"]).update_column(:sms_sent, true) if sms_log.other_info["attendance_id"].present?
        return false
      end
    end
  end
end
