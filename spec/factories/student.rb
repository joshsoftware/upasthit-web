# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    sequence(:registration_no) {|n| n }
    sequence(:roll_no) {|n| n }
    gender { FFaker::Gender.random }
    dob { FFaker::Time.date }
    name { FFaker::Name.name }
    guardian_name { FFaker::Name.name }
    guardian_mobile_no { "91728971277" }
    preferred_language { "en" }
    association :school
    association :standard
  end
end
