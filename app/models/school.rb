# == Schema Information
#
# Table name: schools
#
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  address     :string
#  school_code :string           not null
#  start_time  :time
#  close_time  :time
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class School < ApplicationRecord
  validates :name, :school_code, presence: true

  has_many :students, class_name: "Student"
  has_many :standards, class_name: "Standard"
  has_many :standard_attendances, class_name: "StandardAttendance"
  has_many :staffs, class_name: 'Staff'
end
