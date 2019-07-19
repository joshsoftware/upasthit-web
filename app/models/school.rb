# frozen_string_literal: true

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
  has_many :staffs, class_name: "Staff"
  has_many :timings, class_name: "SchoolTiming"

  def in_json
    as_json(
      except:  %i[created_at updated_at address close_time],
      include: [timings: {only: %i[start_time close_time reminder_time day]}]
    )
  end

  def admin
    staffs.select(&:admin?).first
  end

  def admin_reminder_time(day)
    time = timings.select {|timing| timing.send(day + "?") }.first.reminder_time
    (time + 30.minutes).strftime("%H:%M")
  end
end
