class AlertJob
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(standard, date)
    unless Attendance.where(date: date, standard_id: standard.id).exists?
      Attendance::AdminAlertSms.call(standard.id)
    end
  end
end
