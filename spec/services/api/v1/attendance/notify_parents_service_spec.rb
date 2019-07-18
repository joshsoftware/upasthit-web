# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Attendance::NotifyParentsService do
  let!(:school) { create(:school) }
  let!(:staff) { create(:staff, school_id: school.id, designation: "Admin") }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:students) { create_list(:student, 4, school_id: school.id, standard_id: standard.id) }
  let!(:date) { (DateTime.now - 1.month).strftime("%d/%m/%Y") }
  let!(:service) { Api::V1::Attendance::NotifyParentsService }

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
        let(:attendance) { Attendance.find_by(student_id: absentee.id, date: Time.zone.parse(date)) }
        before do
          allow_any_instance_of(service).to receive(:send_sms).and_return(attendance.update_column(:sms_sent, true))
          serv = service.new(absent_student_attendance_id)
          serv.call
        end
        it "sms_sent is set to true for the student" do
          expect(attendance[:sms_sent]).to eq true
        end
      end

      context "On failed delivery : " do
        context "SMS is sent to absentees guardian alternate number, " do
          context "On sucessful delivery" do
            let(:attendance) { Attendance.find_by(student_id: absentee.id, date: Time.zone.parse(date)) }
            before do
              allow_any_instance_of(service).to receive(:send_sms).and_return(attendance.update_column(:sms_sent, true))
            end
            let!(:sms_service_called) { service.new(absent_student_attendance_id) }
            it "sms_sent is set to true for the student" do
              sms_service_called.call
              expect(attendance[:sms_sent]).to eq true
            end
          end
          context "On failed delivery : " do
            let(:attendance) { Attendance.find_by(student_id: absentee.id, date: Time.zone.parse(date)) }
            before do
              allow_any_instance_of(service).to receive(:send_sms).and_return(attendance.update_column(:sms_sent, false))
            end
            let!(:sms_service_called) { service.new(absent_student_attendance_id) }

            it "sms_sent is set to false" do
              sms_service_called.call
              expect(attendance[:sms_sent]).to eq false
            end
          end
        end
      end
    end
  end
end
