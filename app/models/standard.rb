# == Schema Information
#
# Table name: standards
#
#  id         :bigint(8)        not null, primary key
#  standard   :string
#  section    :string
#  start_time :time
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint(8)
#

class Standard < ApplicationRecord
  has_many :standard_attendances, class_name: "StandardAttendance"
  has_many :attendances, class_name: "Attendance"
  has_many :students, class_name: 'Student'
  belongs_to :school, class_name: "School", foreign_key: "school_id"
  has_and_belongs_to_many :staffs, join_table: :staffs_standards

  validates :standard, uniqueness: {scope: [:section]}

  def name
    self.standard.to_s + ' ' + self.section.to_s
  end
end
