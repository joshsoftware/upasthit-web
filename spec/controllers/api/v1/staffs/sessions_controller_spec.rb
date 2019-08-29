# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Staffs::SessionsController, type: :controller do
  let(:school) { create(:school) }
  let(:staff) { create(:staff_with_standards, school_id: school.id) }

  describe "GET : sync API" do
    context "On success" do
      it "should return json of school data" do
        add_headers
        get :sync
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body["school"].present?).to eq true
        expect(response_body["staff"].count).to eq 1
        expect(response_body["attendances"].count).to eq 2
      end

      it "should return json if headers are present" do
        add_headers
        get :sync
        expect(response.status).to eq(200)
      end
    end

    context "should fail if" do
      it "staff does not exist" do
        request.headers[Figaro.env.X_USER_PIN] = "1234"
        request.headers[Figaro.env.X_USER_MOB_NUM] = "9798845220"
        get :sync
        expect(response.status).to eq(401)
      end

      it "headers are not present" do
        get :sync
        expect(response.status).to eq(401)
      end

      it "headers are not valid" do
        request.headers[Figaro.env.X_USER_PIN] = "12345"
        request.headers[Figaro.env.X_USER_MOB_NUM] = "9798845220"
        get :sync, params: {mobile_number: staff.mobile_number}
        expect(response.status).to eq(401)
      end
    end
  end

  def add_headers
    request.headers[Figaro.env.X_USER_PIN] = staff.pin
    request.headers[Figaro.env.X_USER_MOB_NUM] = staff.mobile_number
  end
end
