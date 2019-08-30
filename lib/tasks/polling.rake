# frozen_string_literal: true

namespace :polling do
  desc "Poling sms delivery reports"
  task sms: :environment do
    PollingJob.new.perform
  end
end
