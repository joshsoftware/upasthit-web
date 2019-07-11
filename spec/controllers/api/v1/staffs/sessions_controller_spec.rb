# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Staffs::SessionsController, type: :controller do
  let(:school) { create(:school) }
  let(:staff) { create(:staff, school_id: school.id) }

  describe "GET : sync API" do
    context "On success" do
      it "should return json of school data" do
        get :sync, params: {mobile_number: staff.mobile_number}
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body["school"].present?).to eq true
        expect(response_body["staff"].count).to eq 1
      end
    end

    context "should fail if" do
      it "staff does not exist" do
        get :sync, params: {mobile_number: "9798845220"}
        expect(response.status).to eq(400)
        response_body = JSON.parse(response.body)
        expect(response_body["errors"]["base"]).to eq [I18n.t("error.invalid_mobile_no")]
      end
    end
  end
end
