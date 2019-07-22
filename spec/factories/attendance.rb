# frozen_string_literal: true

FactoryBot.define do
  factory :attendance do
    date { (DateTime.now - 1.month).strftime("%d/%m/%Y") }
    association :school
    association :standard
    association :student
    present { false }
    sms_sent { false }
  end
end
