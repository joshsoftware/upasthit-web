# frozen_string_literal: true

class AlertJob
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(standard, date)
    Attendance::AdminAlertSms.call(standard.id) unless Attendance.where(date: date, standard_id: standard.id).exists?
  end
end
