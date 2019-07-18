# frozen_string_literal: true

require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Sessions" do
  header "Content-Type", "application/json"
  let(:school) { create(:school) }
  let(:staff_1) { create(:staff_with_standards, school_id: school.id) }
  let(:staff_2) { create(:staff_with_standards, school_id: school.id) }

  before do
    allow_any_instance_of(SchoolTiming).to receive(:update_cron_tab).and_return(true)
    SchoolTiming.days.keys.each do |day|
      FactoryBot.create(:school_timing, school_id: school.id, day: day)
    end
  end

  get "v1/staffs/sync", document: :v1 do
    parameter :mobile_number, "Mobile number of staff", required: true
    let!(:mobile_number) { staff_1.mobile_number }
    let!(:pin) { staff_1.pin }
    let(:raw_post) { params.to_json }
    example "Sync API" do
      do_request
      expect(status).to eq 200
    end
  end
end
