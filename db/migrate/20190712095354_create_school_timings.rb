# frozen_string_literal: true

class CreateSchoolTimings < ActiveRecord::Migration[5.2]
  def change
    create_table :school_timings do |t|
      t.time   :start_time
      t.time   :close_time
      t.integer :day
      t.time :reminder_time
      t.timestamps
    end
  end
end
