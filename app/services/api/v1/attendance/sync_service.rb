# frozen_string_literal: true

module Api
  module V1
    module Attendance
      class SyncService
        include ActiveModel::Validations
        validates_presence_of :date, :school_id
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
          attendances ||= ::Attendance.where("school_id = ? AND date > ?", school_id, date)
          @attendances = attendances.each_with_object({}) do |c, h|
            (h[c.standard_id] ||= []).push(
              id:         c.id,
              date:       c.date,
              present:    c.present,
              student_id: c.student_id,
              sms_sent:   c.sms_sent
            )
          end
        end

        def date
          @date ||= @params[:date]
        end

        def school_id
          @school_id ||= @params[:school_id]
        end

        def validate_date
          Date.parse(@date)
        rescue StandardError
          nil
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
