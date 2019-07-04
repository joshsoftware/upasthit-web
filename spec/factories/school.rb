# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    school_code { "1001" }
    name { FFaker::Education.school }
  end
end