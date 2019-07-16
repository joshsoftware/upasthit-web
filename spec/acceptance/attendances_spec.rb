# frozen_string_literal: true

require "rails_helper"
require "rspec_api_documentation/dsl"

resource "Attendances" do
  header "Content-Type", "application/json"
  let(:school) { create(:school) }
  let!(:staff_1) { create(:staff_with_standards, school_id: school.id) }
  let!(:staff_2) { create(:staff_with_standards, school_id: school.id) }

  before do
    SchoolTiming.days.keys.each do |day|
      FactoryBot.create(:school_timing, school_id: school.id, day: day)
    end
  end

  get "v1/attendances/sync", document: :v1 do
    parameter :date, "Start date (end date is current date)", required: true
    parameter :school_id, "School ID", required: true
    let!(:date) { DateTime.now - 7.months }
    let!(:school_id) { school.id }
    let(:raw_post) { params.to_json }
    example "Sync API" do
      do_request
      expect(status).to eq 200
    end
  end
end
