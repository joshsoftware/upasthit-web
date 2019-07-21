# frozen_string_literal: true

require "rake"
Rails.application.load_tasks

class SchoolTiming < ApplicationRecord
  enum day: %i[monday tuesday wednesday thursday friday saturday]
  validates_uniqueness_of :day, scope: :school_id
  validates_presence_of :start_time, :day, :close_time

  belongs_to :school

  after_commit :update_cron_tab, if: :saved_change_to_reminder_time?

  def update_cron_tab
    Rake::Task["update:crontab"].invoke
  end
end
