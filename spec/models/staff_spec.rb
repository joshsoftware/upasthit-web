# frozen_string_literal: true

require "rails_helper"

RSpec.describe Staff, type: :model do
  let(:school) { create(:school) }
  let(:staff) { create(:staff, school_id: school.id) }

  it "is valid with valid attributes" do
    expect(staff).to be_valid
  end

  context "Invalid when" do
    it "pin is not of length 4" do
      staff.update(pin: "12")
      expect(staff).to_not be_valid
      expect(staff.errors["pin"]).to eq ["is the wrong length (should be 4 characters)"]
    end

    it "mobile number is not unique" do
      duplicate_staff = Staff.create(mobile_number: staff.mobile_number, school_id: school.id,
                              pin: "9788", registration_no: "1000",
                              designation: "ClassTeacher")
      expect(duplicate_staff).to_not be_valid
      expect(duplicate_staff.errors[:mobile_number]).to eq ["has already been taken"]
    end

    it "registration number is not unique" do
      duplicate_staff = Staff.create(mobile_number: "9098726723", school_id: school.id,
                              pin: "9788", registration_no: staff.registration_no,
                              designation: "ClassTeacher")
      expect(duplicate_staff).to_not be_valid
      expect(duplicate_staff.errors[:registration_no]).to eq ["has already been taken"]
    end

    it "designation is not valid" do
      invalid_staff = Staff.create(mobile_number: "8098726723", school_id: school.id,
                              pin: "9788", registration_no: "1000",
                              designation: "Invalid")
      expect(invalid_staff).to_not be_valid
      expect(invalid_staff.errors[:designation]).to eq ["is not included in the list"]
    end
  end
end
