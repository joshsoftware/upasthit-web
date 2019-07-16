# frozen_string_literal: true

namespace :schedule do
  desc "schedule admin alerts"
  task :alerts, [:school_id] => [:environment] do |_t, args|
    school_id = args[:school_id]
    AlertJob.perform_async(school_id, Date.today)
  end
end
