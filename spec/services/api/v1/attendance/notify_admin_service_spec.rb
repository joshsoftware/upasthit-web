# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Attendance::NotifyAdminService do
  let!(:school) { create(:school) }
  let!(:admin) { create(:staff, school_id: school.id, designation: "Admin") }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:students) { create_list(:student, 4, school_id: school.id, standard_id: standard.id) }
  let!(:date) { (DateTime.now - 1.month).strftime("%d/%m/%Y") }
  let!(:service) { Api::V1::Attendance::NotifyAdminService }
  let!(:attendance_1) {
    create(:attendance, school_id: school.id, standard_id: standard.id,
                               student_id: students.last.id, date: date)
  }
  let!(:attendance_2) {
    create(:attendance, school_id: school.id, standard_id: standard.id,
                               student_id: students.second.id, date: date)
  }

  before do
    allow_any_instance_of(service).to receive(:send_sms).with(admin.mobile_number, anything).and_return("SMS sent to Admin")
  end

  let(:sms_service_called) { service.new(school.id, date) }

  it "finds all absentees whose parent's did not receive SMS for the specified date" do
    sms_service_called.call
    defaulters = sms_service_called.instance_variable_get(:@defaulters)
    expect(defaulters.keys[0]).to eq standard.id
    expect(defaulters[standard.id].count).to eq 2
    expect(defaulters[standard.id]).to eq [students.last.roll_no, students.second.roll_no]
  end

  it "sends SMS to admin of school" do
    expect_any_instance_of(service).to receive(:send_sms).with(admin.mobile_number, anything).and_return "SMS sent to Admin"
    sms_service_called.call
  end
end
