# frozen_string_literal: true

class SendSmsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(mobile_number, message, is_admin, receiver_info={}, attendance_id={})
    serv = if CURRENT_MESSAGING_SERVICE == PINNACLE
             SendSmsService.new(mobile_number, message, is_admin, receiver_info, attendance_id)
           else
             SendSmsServiceTextLocal.new(mobile_number, message, is_admin, receiver_info, attendance_id)
           end
    serv.call && Rails.logger.error("SendSmsService: Failed - LOG - PARAMS - Attendance id - #{attendance_id}")
  end
end
