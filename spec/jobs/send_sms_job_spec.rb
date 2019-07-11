# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendSmsJob, type: :job do
  let!(:school) { create(:school) }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:students) { create_list(:student, 4, school_id: school.id, standard_id: standard.id) }

  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      SendSmsJob.perform_later(students.pluck(:id))
    }.to have_enqueued_job(SendSmsJob)
  end
end
