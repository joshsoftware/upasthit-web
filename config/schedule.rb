# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
require "./" + File.dirname(__FILE__) + "/environment.rb"
set :output, "/current/log/cron_log.log"

School.find_each do |school|
  school.timings.find_each do |timing|
    every timing.day, at: school.admin_reminder_time(timing.day) do
      rake "schedule:alerts[#{school.id}]", output: {error: "error.log", standard: "cron.log"}
    end
  end
end

every 5.minutes do
  rake "polling:sms", output: {error: "error.log", standard: "cron.log"}
end
