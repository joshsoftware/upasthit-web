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
  include Discard::Model
  audited
  translates :first_name, :last_name
  globalize_accessors locales: %i[en mr-IN hi-IN], attributes: %i[first_name last_name]
  has_many :attendances, class_name: "Attendance"
  belongs_to :standard, class_name: "Standard", foreign_key: "standard_id"
  belongs_to :school, class_name: "School", foreign_key: "school_id"

  validates :registration_no, :roll_no, :gender, :dob, :guardian_name,
            :guardian_mobile_no, :preferred_language, presence: true

  validates_uniqueness_of :registration_no, conditions: -> { where(discarded_at: nil) }
  validates :preferred_language, inclusion: {in: %w[en mr-IN hi-IN]}

  def full_name
    first_name.to_s + " " + last_name.to_s
  end

  after_discard do
    attendances.discard_all
  end

  after_undiscard do
    attendances.undiscard_all
  end
end

def attendance_status
  attendance = attendances.where("'date' > ?", Date.today.beginning_of_day)
  attendance.count.positive? ? attendance.first.present : ""
end
