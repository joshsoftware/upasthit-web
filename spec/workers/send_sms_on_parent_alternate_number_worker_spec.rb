# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe SendSmsOnParentAlternateNumberWorker, type: :worker do
  let!(:school) { create(:school) }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:student) { create(:student, school_id: school.id, standard_id: standard.id) }
  let!(:date) { "12/12/2019" }
  let!(:attendance_1) {
    create(:attendance, school_id: school.id, standard_id: standard.id,
                               student_id: student.id, date: date)
  }

  it { is_expected.to be_retryable 1 }

  it "enqueues job with arguments" do
    SendSmsOnParentAlternateNumberWorker.perform_async attendance_1.id, "message"

    expect(SendSmsOnParentAlternateNumberWorker).to have_enqueued_sidekiq_job(attendance_1.id, "message")
  end

  it "Raises StandardError if sms is not sent" do
    allow_any_instance_of(SendSmsService).to receive(:sms_sent?).and_return(false)
    Sidekiq::Testing.inline! do
      expect { SendSmsOnParentAlternateNumberWorker.perform_async(attendance_1.id, "message") }.to raise_error StandardError
    end
  end

  it "Does not raise StandardError if sms is sent" do
    allow_any_instance_of(SendSmsService).to receive(:sms_sent?).and_return(true)
    Sidekiq::Testing.inline! do
      expect { SendSmsOnParentAlternateNumberWorker.perform_async(attendance_1.id, "message") }.to_not raise_error StandardError
    end
  end
end
