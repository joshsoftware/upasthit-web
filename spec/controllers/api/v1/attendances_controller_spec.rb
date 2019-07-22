# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AttendancesController, type: :controller do
  let!(:school) { create(:school) }
  let!(:staff) { create(:staff_with_standards, school_id: school.id) }
  let!(:date) { (DateTime.now - 1.month).strftime("%d/%m/%Y") }
  let(:future_date) { (DateTime.now + 3.months).strftime("%d/%m/%Y") }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:students) { create_list(:student, 4, school_id: school.id, standard_id: standard.id) }

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
        total_attendance = Attendance.where(date: Time.parse(date), standard_id: standard.id, school_id: school.id)
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
          comments: "#{date} #{school.school_code} #{standard.standard}-#{standard.section} #{students.first.roll_no}"
        }
        post :sms_callback, params: valid_params
      end

      it { is_expected.to respond_with 200 }

      it "creates new attendance record for standard" do
        expect(StandardAttendance.count).to eq 1
      end

      it "marks attendance for all students of the standard" do
        total_attendance = Attendance.where(date: Time.parse(date), standard_id: standard.id, school_id: school.id)
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
          comments: "#{date} #{school.school_code} #{standard.standard}#{standard.section} #{students.first.roll_no}"
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
        invalid_params[:comments] = "#{date} 12113 #{standard.standard}-#{standard.section} #{students.first.roll_no}"
        post :sms_callback, params: invalid_params
        is_expected.to respond_with 400
        response_body = JSON.parse(response.body)
        expect(response_body["errors"]["base"]).to eq ["Invalid School Code", "Invalid Standard Id"]
      end
    end
  end

  describe "GET : sync API" do
    context "On success" do
      it "should return json of attendances starting from date given till currrent date" do
        get :sync, params: {school_id: school.id, date: date}
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body["attendances"].count).to eq 2
      end
    end

    context "should fail if" do
      it "date is not given in params" do
        get :sync, params: {school_id: school.id}
        expect(response.status).to eq(422)
        response_body = JSON.parse(response.body)
        expect(response_body["message"]).to eq "Please enter date"
      end

      it "date format is invalid" do
        get :sync, params: {school_id: school.id, date: "12.01.2019"}
        expect(response.status).to eq(422)
        response_body = JSON.parse(response.body)
        expect(response_body["message"]).to eq "Invalid Date"
      end

      it "date given is in future" do
        get :sync, params: {date: future_date, school_id: school.id}
        expect(response.status).to eq(400)
        response_body = JSON.parse(response.body)
        expect(response_body["errors"]["base"]).to eq ["Date cannot be in future"]
      end

      it "school_id is not given in params" do
        get :sync, params: {date: date}
        expect(response.status).to eq(400)
        response_body = JSON.parse(response.body)
        expect(response_body["errors"]["school_id"]).to eq ["can't be blank"]
      end

      it "school_id is not valid" do
        get :sync, params: {date: date, school_id: 11_212}
        expect(response.status).to eq(400)
        response_body = JSON.parse(response.body)
        expect(response_body["errors"]["base"]).to eq ["Invalid School ID"]
      end
    end
  end
end
