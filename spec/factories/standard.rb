# frozen_string_literal: true

FactoryBot.define do
  factory :standard do
    sequence(:standard, 10) {|n| n }
    association :school
    section { "A" }
    factory :standard_with_students do
      after(:create) do |standard|
        create_list(:student_with_attendances, 3, school_id: standard.school_id, standard: standard)
      end
    end
  end
end
