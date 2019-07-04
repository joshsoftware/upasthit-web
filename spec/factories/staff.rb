# frozen_string_literal: true

FactoryBot.define do
  factory :staff do
    mobile_number { "9999999999" }
    password { FFaker::Internet.password }
    registration_no { "1234" }
    designation { "ClassTeacher" }
    pin { "1212" }
  end
end
