# frozen_string_literal: true

class SendSmsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(mobile_number, message, is_admin, attendance_id={})
    serv = SendSmsService.new(mobile_number, message, is_admin, attendance_id)
    if serv.call
      raise StandardError unless serv.sms_sent?
    else
      Rails.logger.error("SendSmsService: Failed #{serv.formatted_errors}")
    end
  end
end
