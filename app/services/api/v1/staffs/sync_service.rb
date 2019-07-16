# frozen_string_literal: true

module Api
  module V1
    module Staffs
      class SyncService
        include ActiveModel::Validations
        validates :mobile, format: {with: /\A[346789][0-9]{9}\z/}

        def initialize(params)
          @params = params
        end

        def sync
          return false unless valid?

          check_staff_present &&
          set_result
        end

        attr_reader :result

        private

        def mobile
          @params[:mobile_number]
        end

        def check_staff_present
          return true if staff.present?

          errors.add(:base, I18n.t("error.invalid_mobile_no"))
          false
        end

        def staff
          @staff ||= Staff.find_by(mobile_number: mobile)
        end

        def school
          @school ||= staff.school
        end

        def standards
          school.standards.all.includes(:students)
        end

        def school_staffs
          school.staffs.all.includes(:standards)
        end

        def attendances
          attendances = ::Attendance.where("date BETWEEN ? AND ?", DateTime.now.beginning_of_month, DateTime.now.end_of_day).all
          attendances.each_with_object({}) do |c, h|
            (h[c.standard_id] ||= []).push(
              id:         c.id,
              date:       c.date,
              present:    c.present,
              student_id: c.student_id,
              sms_sent:   c.sms_sent
            )
          end
        end

        def set_result
          @result = {
            school:      school.in_json,
            staff:       school_staffs.map(&:in_json),
            standard:    standards.map(&:in_json),
            attendances: attendances
          }
        end
      end
    end
  end
end
