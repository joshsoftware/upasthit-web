# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
require "./" + File.dirname(__FILE__) + "/environment.rb"
set :output, "/current/log/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
School.all.each do |school|
  every :day, at: school.todays_admin_reminder_time do
    rake "schedule:alerts[#{school.id}]", output: {error: "error.log", standard: "cron.log"}
  end
end
