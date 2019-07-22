# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendSmsService do
  let!(:school) { create(:school) }
  let!(:admin) { create(:staff, school_id: school.id, designation: "Admin") }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:student) { create(:student, school_id: school.id, standard_id: standard.id) }
  let!(:date) { (DateTime.now - 1.month).strftime("%d/%m/%Y") }
  let!(:service) { SendSmsService }
  let(:attendance_1) {
    create(:attendance, school_id: school.id, standard_id: standard.id,
                               student_id: student.id, date: date)
  }

  before do
    allow_any_instance_of(service).to receive(:perform).and_return(true)
    allow_any_instance_of(service).to receive(:sms_sent?).and_return(true)
  end

  let(:sms_service_called) { service.new(student.guardian_mobile_no, "message", false, attendance_1.id) }

  it "sends sms to a mobile number with a message" do
    expect_any_instance_of(service).to receive(:perform).and_return true
    sms_service_called.call
  end

  context "updates attendance" do
    it "sms_sent is set as true if sms is delivered" do
      allow_any_instance_of(service).to receive(:sms_sent).and_return(true)
      sms_service_called.call
      attendance_1.reload
      expect(attendance_1.sms_sent).to eq true
    end
    it "sms_sent is set as false if sms is not delivered" do
      allow_any_instance_of(service).to receive(:sms_sent).and_return(false)
      sms_service_called.call
      attendance_1.reload
      expect(attendance_1.sms_sent).to eq false
    end
  end

  it "does not update attendance if sms is sent to admin" do
    expect(attendance_1.sms_sent).to eq false
    allow_any_instance_of(service).to receive(:sms_sent).and_return(true)
    service.new(admin.mobile_number, "message", true, attendance_1.id).call
    expect(attendance_1.sms_sent).to eq false
  end
end
