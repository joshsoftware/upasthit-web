# frozen_string_literal: true

FactoryBot.define do
  factory :staff do
    sequence(:mobile_number) {|n| "77988#{n.divmod(10).first}#{n.divmod(10).second}221" }
    password { FFaker::Internet.password }
    designation { "ClassTeacher" }
    pin { "1212" }
    first_name { FFaker::Name.first_name }
    last_name { FFaker::Name.last_name }
    association :school
    factory :staff_with_standards do
      after(:create) do |staff|
        create_list(:standard_with_students, 2, school_id: staff.school_id, staffs: [staff])
      end
    end
  end
end
