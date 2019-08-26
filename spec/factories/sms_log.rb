# frozen_string_literal: true

FactoryBot.define do
  factory :sms_log do
    sequence(:sender_mobile) {|n| "77988#{n.divmod(10).first}#{n.divmod(10).second}221" }
    sequence(:receiver_mobile) {|n| "77988#{n.divmod(10).first}#{n.divmod(10).second}221" }
    sender_type { "Server" }
    receiver_type { "Student" }
    sender_id {|n| n }
    receiver_id {|n| n }
    association :receiver
    association :sender
  end
end
