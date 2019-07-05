# frozen_string_literal: true

FactoryBot.define do
  factory :staff do
    sequence(:mobile_number) {|n| "77988#{n}5221" }
    password { FFaker::Internet.password }
    sequence(:registration_no) {|n| n }
    designation { "ClassTeacher" }
    pin { "1212" }
    name { FFaker::Name.name }
    association :school
    factory :staff_with_standards do
      after(:create) do |staff|
        create_list(:standard_with_students, 2, school_id: staff.school_id, staffs: [staff])
      end
    end
  end
end
