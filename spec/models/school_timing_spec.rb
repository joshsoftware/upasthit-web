# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolTiming, type: :model do
  let!(:school) { create(:school) }

  before do
    allow_any_instance_of(SchoolTiming).to receive(:update_cron_tab).and_return(true)
    SchoolTiming.days.keys.each do |day|
      FactoryBot.create(:school_timing, school_id: school.id, day: day)
    end
  end

  context "A valid school timing" do
    it { should belong_to(:school).class_name("School") }
    it { should validate_presence_of(:start_time) }
    it { should validate_presence_of(:close_time) }
    it { should validate_presence_of(:day) }
    it { should define_enum_for(:day).with(%i[monday tuesday wednesday thursday friday saturday]) }
    it { should validate_uniqueness_of(:day).scoped_to(:school_id).ignoring_case_sensitivity }
  end

  it "runs update:crontab rake task when reminder time changes" do
    timing = school.timings.first
    expect_any_instance_of(SchoolTiming).to receive(:update_cron_tab).and_return(true)
    timing.update(reminder_time: timing.reminder_time + 30.minutes)
  end
end
