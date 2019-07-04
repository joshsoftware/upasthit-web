# frozen_string_literal: true

require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Sessions" do
  header "Content-Type", "application/json"
  let(:school) { create(:school) }
  let!(:staff_1) { create(:staff_with_standards, school_id: school.id) }
  let!(:staff_2) { create(:staff_with_standards, school_id: school.id) }

  get "api/staffs/sync" do
    parameter :mobile_number, "Mobile number of staff", required: true
    parameter :pin, "4 digit PIN"
    let!(:mobile_number) { staff_1.mobile_number }
    let!(:pin) { "1234" }
    let(:raw_post) { params.to_json }
    example "Sync API" do
      do_request
      expect(status).to eq 200
    end
  end
end
