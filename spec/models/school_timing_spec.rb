# frozen_string_literal: true

require "rails_helper"

RSpec.describe SchoolTiming, type: :model do
  let!(:school) { create(:school) }

  before do
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
end
