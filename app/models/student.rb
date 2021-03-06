# frozen_string_literal: true

# == Schema Information
#
# Table name: students
#
#  id                           :bigint(8)        not null, primary key
#  registration_no              :string
#  roll_no                      :integer
#  gender                       :string
#  dob                          :datetime
#  guardian_name                :string
#  guardian_mobile_no           :string
#  guardian_alternate_mobile_no :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  address                      :string
#  school_id                    :bigint(8)
#  standard_id                  :bigint(8)
#

class Student < ApplicationRecord
  translates :last_name, :first_name
  globalize_accessors locales: %i[en mr-IN hi-IN], attributes: %i[first_name last_name]
  has_many :attendances, class_name: "Attendance"
  has_many :sms_logs, as: :receiver
  belongs_to :standard, class_name: "Standard", foreign_key: "standard_id"
  belongs_to :school, class_name: "School", foreign_key: "school_id"

  validates :roll_no, :gender, :dob, :guardian_name, :guardian_mobile_no, :preferred_language, :registration_no, presence: true
  validates :preferred_language, inclusion: {in: %w[en mr-IN hi-IN]}
  validates :registration_no, uniqueness: true

  def full_name
    first_name + " " + last_name
  end
end

def attendance_status
  attendance = attendances.where("'date' > ?", Date.today.beginning_of_day)
  attendance.count.positive? ? attendance.first.present : ""
end
