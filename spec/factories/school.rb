# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    school_code { "1001" }
    name { FFaker::Education.school }
    email { FFaker::Internet.email }
    contact_number { "91728971277" }
  end
end
