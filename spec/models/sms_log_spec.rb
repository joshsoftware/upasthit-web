# frozen_string_literal: true

require "rails_helper"

RSpec.describe SmsLog, type: :model do
  it { is_expected.to have_db_column(:receiver_id).of_type(:integer) }
  it { is_expected.to have_db_column(:receiver_type).of_type(:string) }
  it { is_expected.to have_db_column(:receiver_mobile).of_type(:string) }
  it { is_expected.to have_db_column(:sender_id).of_type(:integer) }
  it { is_expected.to have_db_column(:sender_type).of_type(:string) }
  it { is_expected.to have_db_column(:sender_mobile).of_type(:string) }
  it { is_expected.to have_db_column(:content).of_type(:string) }
  it { is_expected.to have_db_column(:message_token).of_type(:string) }
  it { is_expected.to have_db_column(:number_type).of_type(:integer) }
  it { is_expected.to belong_to(:sender) }
  it { is_expected.to belong_to(:receiver) }

  it "should create the sms log" do
    previous_count = SmsLog.count
    sms_log_hash = {sender_mobile: "1222353333", receiver_mobile: "1234567890", content: "Test Message", to: "Student", message_token: "message_token", student_id: 1, from: "Server"}
    SmsLog.generate(sms_log_hash)
    expect(SmsLog.count).to eq(previous_count + 1)
  end

  it "should fail if the wrong number of argument passed" do
    expect(SmsLog.method(:generate).arity).to eq(-1)
  end
end
