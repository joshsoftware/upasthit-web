# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AttendancesController, type: :controller do
  let!(:school) { create(:school) }
  let!(:staff) { create(:staff, school_id: school.id) }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:students) { create_list(:student, 4, school_id: school.id, standard_id: standard.id) }
  let!(:date) { Time.zone.parse("12/12/2019") }

  describe "POST #create" do
    context "with valid params" do
      before do
        valid_params = {
          standard:        Standard.last.standard,
          school_code:     school.school_code,
          date:            date,
          section:         Standard.last.section,
          absent_roll_nos: [students.first.roll_no]
        }
        post :create, params: valid_params
      end

      it { is_expected.to respond_with 200 }

      it "creates new attendance record for standard" do
        expect(StandardAttendance.count).to eq 1
      end

      it "marks attendance for all students of the standard" do
        total_attendance = Attendance.where(date: date, standard_id: standard.id, school_id: school.id)
        expect(total_attendance.count).to eq students.count
        absentee_attendance = total_attendance.where(present: false)
        expect(absentee_attendance.count).to eq 1
        expect(absentee_attendance.pluck(:student_id)).to include(students.first.id)
      end
    end

    context "with invalid params" do
      before do
        invalid_params = {
          standard:        1000,
          school_code:     school.school_code,
          date:            date,
          section:         Standard.last.section,
          absent_roll_nos: [students.first.roll_no]
        }
        post :create, params: invalid_params
      end

      it { is_expected.to respond_with 400 }

      it "renders error messages" do
        response_body = JSON.parse(response.body)
        expect(response_body["errors"]["base"]).to eq ["Invalid Standard Id"]
      end
    end
  end

  describe "POST #sms_callback" do
    context "with valid params" do
      before do
        valid_params = {
          sender:   Figaro.env.AUTHORISED_SENDER,
          comments: "12/12/2019 #{school.school_code} #{standard.standard}-#{standard.section} #{students.first.roll_no}"
        }
        post :sms_callback, params: valid_params
      end

      it { is_expected.to respond_with 200 }

      it "creates new attendance record for standard" do
        expect(StandardAttendance.count).to eq 1
      end

      it "marks attendance for all students of the standard" do
        total_attendance = Attendance.where(date: date, standard_id: standard.id, school_id: school.id)
        expect(total_attendance.count).to eq students.count
        absentee_attendance = total_attendance.where(present: false)
        expect(absentee_attendance.count).to eq 1
        expect(absentee_attendance.pluck(:student_id)).to include(students.first.id)
      end
    end

    context "with invalid params" do
      let!(:invalid_params) {
        {
          sender:   "98297218272",
          comments: "12/12/2019 #{school.school_code} #{standard.standard}#{standard.section} #{students.first.roll_no}"
        }
      }

      it "fails when sender is not authorized" do
        post :sms_callback, params: invalid_params
        is_expected.to respond_with 422
        response_body = JSON.parse(response.body)
        expect(response_body["message"]).to eq "SMS Sender is not authorized"
      end

      it "fails and renders error when message format is invalid" do
        invalid_params[:sender] = Figaro.env.AUTHORISED_SENDER
        post :sms_callback, params: invalid_params
        is_expected.to respond_with 422
        response_body = JSON.parse(response.body)
        expect(response_body["message"]).to eq "Message format is invalid"
      end

      it "fails and renders error when message has invalid values" do
        invalid_params[:sender] = Figaro.env.AUTHORISED_SENDER
        invalid_params[:comments] = "12/12/2019 12113 #{standard.standard}-#{standard.section} #{students.first.roll_no}"
        post :sms_callback, params: invalid_params
        is_expected.to respond_with 400
        response_body = JSON.parse(response.body)
        expect(response_body["errors"]["base"]).to eq ["Invalid School Code", "Invalid Standard Id"]
      end
    end
  end
end
