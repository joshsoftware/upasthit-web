# frozen_string_literal: true

namespace :schedule do
  desc "schedule admin alerts"
  task alerts: :environment do
    School.each do |school|
      AlertJob.perform_later(school.id, Date.today)
    end
  end
end
