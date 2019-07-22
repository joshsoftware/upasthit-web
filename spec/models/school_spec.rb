# frozen_string_literal: true

require "rails_helper"

RSpec.describe School, type: :model do
  let(:school) { create(:school) }

  before do
    allow_any_instance_of(SchoolTiming).to receive(:update_cron_tab).and_return(true)
    SchoolTiming.days.keys.each do |day|
      FactoryBot.create(:school_timing, school_id: school.id, day: day)
    end
  end

  it "is valid with valid attributes" do
    expect(school).to be_valid
  end

  context "Invalid when" do
    it "school code is not present" do
      invalid_school = School.create(name: FFaker::Education.school)
      expect(invalid_school).to_not be_valid
      expect(invalid_school.errors["school_code"]).to eq ["can't be blank"]
    end

    it "Name is not present" do
      invalid_school = School.create(school_code: "1")
      expect(invalid_school).to_not be_valid
      expect(invalid_school.errors["name"]).to eq ["can't be blank"]
    end
  end

  context "has method admin_reminder_time" do
    it "accepts day of week and gives reminder time of that day" do
      reminder_time = school.timings.select(&:monday?).first.reminder_time + 30.minutes
      expect(school.admin_reminder_time("monday")).to eq reminder_time.strftime("%H:%M")
    end
  end
end
