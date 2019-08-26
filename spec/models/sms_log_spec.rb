require 'rails_helper'

RSpec.describe SmsLog, type: :model do
	#pending "add some examples to (or delete) #{__FILE__}"
	it { is_expected.to have_db_column(:receiver_id).of_type(:integer) }
	it { is_expected.to have_db_column(:receiver_type).of_type(:string) }
	it { is_expected.to have_db_column(:receiver_mobile).of_type(:string) }
	it { is_expected.to have_db_column(:sender_id).of_type(:integer) }
	it { is_expected.to have_db_column(:sender_type).of_type(:string) }
	it { is_expected.to have_db_column(:sender_mobile).of_type(:string) }
	it { is_expected.to have_db_column(:is_delivered).of_type(:boolean) }
	it { is_expected.to have_db_column(:content).of_type(:string) }
	it { is_expected.to have_db_column(:is_delivered).of_type(:boolean) }
	it { is_expected.to have_db_column(:message_token).of_type(:string) }

	it { is_expected.to belong_to(:sender) }
	it { is_expected.to belong_to(:receiver) }

	it "should update the is_delivered to true" do
		sms_log = SmsLog.create
  		sms_log.delivered
		expect(sms_log.is_delivered).to eq true
	end

	it "should create the sms log" do
		previous_count = SmsLog.count
  		SmsLog.generate("0987654321", "1234567890", "Test Message", "Student", "message_token", 1)
		expect(SmsLog.count).to eq (previous_count+1)
	end

	it "should fail if the wrong number of argument passed" do
		expect(SmsLog.method(:generate).arity).to eq -7
	end
end
