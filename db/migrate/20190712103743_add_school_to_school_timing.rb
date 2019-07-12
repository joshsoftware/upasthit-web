# frozen_string_literal: true

class AddSchoolToSchoolTiming < ActiveRecord::Migration[5.2]
  def change
    add_reference :school_timings, :school, index: true
  end
end
