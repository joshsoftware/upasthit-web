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

School.find_each do |school|
  every  :monday, at: school.admin_reminder_time("monday") do
    rake "schedule:alerts[#{school.id}]", output: {error: "error.log", standard: "cron.log"}
  end
end
School.find_each do |school|
  every :tuesday, at: school.admin_reminder_time("tuesday") do
    rake "schedule:alerts[#{school.id}]", output: {error: "error.log", standard: "cron.log"}
  end
end
School.find_each do |school|
  every :wednesday, at: school.admin_reminder_time("wednesday") do
    rake "schedule:alerts[#{school.id}]", output: {error: "error.log", standard: "cron.log"}
  end
end
School.find_each do |school|
  every :thursday, at: school.admin_reminder_time("thursday") do
    rake "schedule:alerts[#{school.id}]", output: {error: "error.log", standard: "cron.log"}
  end
end
School.find_each do |school|
  every :friday, at: school.admin_reminder_time("friday") do
    rake "schedule:alerts[#{school.id}]", output: {error: "error.log", standard: "cron.log"}
  end
end
School.find_each do |school|
  every :saturday, at: school.admin_reminder_time("saturday") do
    rake "schedule:alerts[#{school.id}]", output: {error: "error.log", standard: "cron.log"}
  end
end
