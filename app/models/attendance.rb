# == Schema Information
#
# Table name: attendances
#
#  id          :bigint(8)        not null, primary key
#  date        :datetime
#  present     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  standard_id :bigint(8)
#  student_id  :bigint(8)
#  school_id   :bigint(8)
#  sms_sent    :boolean
#

class Attendance < ApplicationRecord

  belongs_to :student, class_name: "Student", foreign_key:"student_id"
  belongs_to :standard, class_name: "Standard", foreign_key:"standard_id"
  belongs_to :school, class_name: "School", foreign_key: "school_id"
end
