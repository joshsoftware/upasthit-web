# frozen_string_literal: true

module Api
  module V1
    module Attendance
      class SyncService
        include ActiveModel::Validations
        validates_presence_of :school_id
        validate :validate_school_id
        validate :validate_date

        def initialize(params)
          @params = params
        end

        def sync
          return false unless valid?

          find_attendances &&
          set_result
        end

        attr_reader :result

        private

        def find_attendances
          @attendances = ::Attendance.where("school_id = ? AND date > ?", school_id, date)
                                     .select(:id, :standard_id, :date, :present, :student_id, :sms_sent)
                                     .group_by(&:standard_id).as_json
        end

        def validate_date
          return unless date > DateTime.now

          errors.add(:base, "Date cannot be in future")
          false
        end

        def validate_school_id
          school = School.find_by_id(school_id)
          return if school.present?

          errors.add(:base, "Invalid School ID")
          false
        end

        def date
          @date ||= Date.parse(@params[:date])
        end

        def school_id
          @school_id ||= @params[:school_id]
        end

        def set_result
          @result = {
            attendances: @attendances
          }
        end
      end
    end
  end
end
