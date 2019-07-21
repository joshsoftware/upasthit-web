# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"
Sidekiq::Testing.fake!

RSpec.describe SendSmsOnParentPrimaryNumberWorker, type: :worker do
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
    SendSmsOnParentPrimaryNumberWorker.perform_async attendance_1.id, "message"

    expect(SendSmsOnParentPrimaryNumberWorker).to have_enqueued_sidekiq_job(attendance_1.id, "message")
  end

  it "should call send_sms_on_alternate_number method when retries exhausted" do
    args = {"args" => [attendance_1.id, "message"]}
    SendSmsOnParentPrimaryNumberWorker.within_sidekiq_retries_exhausted_block(args) {
      expect(SendSmsOnParentPrimaryNumberWorker).to receive(:send_sms_on_alternate_number).with(
        args["args"][0], args["args"][1]
      )
    }
  end

  it "should enqueue SendSmsOnParentAlternateNumber worker when retries exhausted" do
    ActiveJob::Base.queue_adapter = :test
    args = {"args" => [attendance_1.id, "message"]}
    expect {
      SendSmsOnParentPrimaryNumberWorker.within_sidekiq_retries_exhausted_block(args) {
        expect(SendSmsOnParentPrimaryNumberWorker).to receive(:send_sms_on_alternate_number).with(
          args["args"][0], args["args"][1]
        )
      } .to have_enqueued_job(SendSmsOnParentAlternateNumberWorker)
    }
  end

  it "Raises StandardError if sms is not sent" do
    allow_any_instance_of(SendSmsService).to receive(:sms_sent?).and_return(false)
    Sidekiq::Testing.inline! do
      expect { SendSmsOnParentPrimaryNumberWorker.perform_async(attendance_1.id, "message") }.to raise_error StandardError
    end
  end

  it "Does not raise StandardError if sms is sent" do
    allow_any_instance_of(SendSmsService).to receive(:sms_sent?).and_return(true)
    Sidekiq::Testing.inline! do
      expect { SendSmsOnParentPrimaryNumberWorker.perform_async(attendance_1.id, "message") }.to_not raise_error StandardError
    end
  end
end
