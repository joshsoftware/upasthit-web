# frozen_string_literal: true

class AlertJob
  include Sidekiq::Worker

  sidekiq_options retry: 1

  def perform(school_id, date)
    serv = Api::V1::Attendance::NotifyAdminService.new(school_id, date)
    return true if serv.call

    Rails.logger.error("NotifyAdminService: Failed #{serv}")
  end
end
