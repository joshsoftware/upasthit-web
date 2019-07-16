# frozen_string_literal: true

class SendSmsOnParentAlternateNumberWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(mobile_number, message, attendance_id)
    SendSmsWorker.new.perform(mobile_number, message, false, attendance_id)
  end
end
