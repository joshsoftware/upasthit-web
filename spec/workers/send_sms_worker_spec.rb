# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe SendSmsWorker, type: :worker do
  let!(:school) { create(:school) }
  let!(:standard) { create(:standard, school_id: school.id) }
  let!(:student) { create(:student, school_id: school.id, standard_id: standard.id) }
  let!(:date) { "12/12/2019" }
  let!(:attendance_1) {
    create(:attendance, school_id: school.id, standard_id: standard.id,
                               student_id: student.id, date: date)
  }

  it { is_expected.to be_retryable 3 }

  it "enqueues itself with arguments when called" do
    SendSmsWorker.perform_async student.guardian_mobile_no, "message", false

    expect(SendSmsWorker).to have_enqueued_sidekiq_job(student.guardian_mobile_no, "message", false)
  end

  it "raises StandardError when sms is not sent" do
    allow_any_instance_of(SendSmsService).to receive(:sms_sent?).and_return(false)
    Sidekiq::Testing.inline! do
      expect { SendSmsWorker.new.perform(student.guardian_mobile_no, "message", false, attendance_1.id) }.to raise_error StandardError
    end
  end

  it "Does not raise StandardError if sms is sent" do
    allow_any_instance_of(SendSmsService).to receive(:sms_sent?).and_return(true)
    Sidekiq::Testing.inline! do
      expect { SendSmsWorker.new.perform(student.guardian_mobile_no, "message", false, attendance_1.id) }.to_not raise_error StandardError
    end
  end
end
