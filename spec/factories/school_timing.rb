# frozen_string_literal: true

FactoryBot.define do
  factory :school_timing do
    start_time { "08:00:00" }
    close_time { "14:00:00" }
    reminder_time { "10:00:00" }
    association :school
  end
end
