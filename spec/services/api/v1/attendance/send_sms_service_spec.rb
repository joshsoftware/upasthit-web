# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Attendance::SendSmsService do
  let!(:school) { create(:school) }
  let!(:staff) { create(:staff, school_id: school.id, designation: "Admin") }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:students) { create_list(:student, 4, school_id: school.id, standard_id: standard.id) }
  let!(:date) { "12/12/2019" }
  let!(:service) { Api::V1::Attendance::SendSmsService }

  before do
    valid_params =
      {
        standard:        Standard.last.standard,
        school_code:     school.school_code,
        date:            date,
        section:         Standard.last.section,
        absent_roll_nos: [students.last.roll_no]
      }
    Api::V1::Attendance::CreateService.new(valid_params).create
  end

  let!(:absent_student_attendance_id) {
    Attendance.where(student_id: students.last.id,
                              date: Time.zone.parse(date), present: false).pluck(:id)
  }

  context "SMS" do
    let!(:absentee) { students.last }

    context "sent to absentees guardian primary number, " do
      context "On sucessful delivery" do
        before do
          allow_any_instance_of(service).to receive(:send_sms).and_return("success")
          service.new(absent_student_attendance_id)
        end
        it "sms_sent is set to true for the student" do
          attendance = Attendance.find_by(student_id: absentee.id, date: Time.zone.parse(date))
          expect(attendance[:sms_sent]).to eq true
        end
      end

      context "On failed delivery : " do
        context "SMS is sent to absentees guardian alternate number, " do
          context "On sucessful delivery" do
            before do
              allow_any_instance_of(service).to receive(:send_sms).and_return("success")
            end
            let!(:sms_service_called) { service.new(absent_student_attendance_id) }
            it "sms_sent is set to true for the student" do
              sms_service_called
              attendance = Attendance.find_by(student_id: absentee.id, date: Time.zone.parse(date))
              expect(attendance[:sms_sent]).to eq true
            end

            it "student is not added to defaulters list" do
              sms_service_called
              defaulters = sms_service_called.instance_variable_get(:@defaulters)
              expect(defaulters.pluck(:id)).to_not include(absentee.id)
            end
          end
          context "On failed delivery : " do
            before do
              allow_any_instance_of(service).to receive(:send_sms).with(anything, "#{absentee.name}#{I18n.translate('sms.absent')}\n").and_return("failure")
              allow_any_instance_of(service).to receive(:send_sms).with(
                staff.mobile_number, I18n.translate("sms.notify_admin", roll_nos: absentee.roll_no.to_s,
                                                                        standard: absentee.standard.standard.to_s + "-" + absentee.standard.section.to_s)
              ).and_return("success")
            end
            let!(:sms_service_called) { service.new(absent_student_attendance_id) }

            it "sms_sent is set to false" do
              sms_service_called
              attendance = Attendance.find_by(student_id: absentee.id, date: Time.zone.parse(date))
              expect(attendance[:sms_sent]).to eq false
            end

            it "absentee data is added to defaulter list" do
              sms_service_called
              defaulters = sms_service_called.instance_variable_get(:@defaulters)
              expect(defaulters.count).to eq 1
              expect(defaulters.pluck(:roll_no)).to include(absentee.roll_no)
            end
            it "SMS is sent to Admin with defaulter list"
          end
        end
      end
    end
  end
end
