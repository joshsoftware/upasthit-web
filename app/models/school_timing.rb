# frozen_string_literal: true

class SchoolTiming < ApplicationRecord
  enum day: %i[monday tuesday wednesday thursday friday saturday]
  validates_uniqueness_of :day, scope: :school_id
  validates_presence_of :start_time, :day, :close_time

  belongs_to :school
end
