# frozen_string_literal: true

module Api
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

      def set_result
        @result = {
          school:   school.in_json,
          staff:    school_staffs.map(&:in_json),
          standard: standards.map(&:in_json)
        }
      end
    end
  end
end
