# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AttendancesController, type: :controller do
  let!(:school) { create(:school) }
  let!(:staff) { create(:staff_with_standards, school_id: school.id) }
  let!(:date) { (DateTime.now - 1.month).strftime("%d/%m/%Y") }
  let(:future_date) { (DateTime.now + 3.months).strftime("%d/%m/%Y") }

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
