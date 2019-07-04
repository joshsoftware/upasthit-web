# frozen_string_literal: true

require "rails_helper"

RSpec.describe School, type: :model do
  let(:school) { create(:school) }

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
end
