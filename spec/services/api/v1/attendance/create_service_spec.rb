# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Attendance::CreateService do
  let!(:school) { create(:school) }
  let!(:staff) { create(:staff, school_id: school.id) }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:students) { create_list(:student, 4, school_id: school.id, standard_id: standard.id) }
  let!(:date) { "12/12/2019" }
  let!(:service) { Api::V1::Attendance::CreateService }

  context "On success" do
    let!(:valid_params) {
      {
        standard:        Standard.last.standard,
        school_code:     school.school_code,
        date:            date,
        section:         Standard.last.section,
        absent_roll_nos: [students.first.roll_no]
      }
    }

    it "renders success message " do
      result = service.new(valid_params).create
      expect(result[:message]).to eq "Done."
    end

    it "marks attendance of students of a standard" do
      service.new(valid_params).create
      total_attendance = Attendance.where(date: Time.zone.parse(date), standard_id: standard.id, school_id: school.id)
      expect(total_attendance.count).to eq students.count
      absentee_attendance = total_attendance.where(present: false)
      expect(absentee_attendance.count).to eq 1
      expect(absentee_attendance.pluck(:student_id)).to include(students.first.id)
    end
  end

  context "Fails when" do
    let!(:invalid_params) {
      {
        standard:        "121",
        school_code:     school.school_code,
        date:            date,
        section:         Standard.last.section,
        absent_roll_nos: [students.first.roll_no]
      }
    }

    it "invalid params are given" do
      expect(service.new(invalid_params).create).to eq false
    end
  end
end
