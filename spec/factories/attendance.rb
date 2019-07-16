# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    date { "12/12/2019" }
    association :school
    association :standard
    association :student
    present { false }
    sms_sent { false }
  end
end
