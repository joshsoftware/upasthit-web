# frozen_string_literal: true

# Responsible for importing item master vessel tags
module Api
  module Attendance
    class CreateService
      include ActiveModel::Validations
      validates :school_code, :date, :standard_id, presence: true
      validate :validate_school_code
      validate :validate_standard_with_section
      validate :validate_date

      def initialize(params={})
        @params = params || {}
      end

      def create
        return false unless valid?

        mark_attendance &&
        set_result
      end

      attr_reader :params, :result

      private

      def mark_attendance
        student_ids ||= standard.students.pluck(:id)
        attendances = student_ids.map do |student_id|
          ::Attendance.find_or_create_by(
            present:     !absent_student_ids.include?(student_id),
            date:        date,
            school_id:   school_id,
            standard_id: standard_id,
            student_id:  student_id
          )
        end

        absent_student_attendance_ids = attendances.map do |attendance|
          attendance.id if absent_student_ids.include?(attendance.student_id) && attendance.date == date
        end
        send_sms(absent_student_attendance_ids)
        StandardAttendance.where(date: date, school_id: school_id,
                                 standard_id: standard_id).first_or_create do |standard_attendance|
          standard_attendance.update(attendance_marked:     true,
                                     no_of_student_present: present_student_count,
                                     no_of_absent_student:  present_student_count(false))
        end
      end

      def send_sms(absent_student_attendance_ids)
        return true unless absent_student_attendance_ids.present?

        SendSmsService.call(absent_student_attendance_ids)
      end

      def present_student_count(present=true)
        ::Attendance.where(date: date, school_id: school_id, standard_id: standard_id,
                           present: present).distinct.count(:student_id)
      end

      def school_code
        params[:school_code]
      end

      def date
        Time.zone.parse(params[:date])
      end

      def standard_id
        params[:standard_id]
      end

      def section
        params[:section]
      end

      def absent_roll_nos
        params[:absent_roll_nos] || []
      end

      def validate_school_code
        return true if school_id

        errors.add(:base, "Invalid School Code")
        false
      end

      def validate_standard_with_section
        return true if standard

        errors.add(:base, "Invalid Standard Id")
        false
      end

      def validate_date
        Date.parse(date)
      rescue StandardError
        nil
      end

      def standard
        @standard ||= Standard.includes(:students).find_by(id: standard_id, school_id: school_id, section: section)
      end

      def school_id
        @school_id ||= School.find_by(school_code: school_code).id
      end

      def absent_student_ids
        return [] unless absent_roll_nos.present?

        @absent_student_ids ||= Student.where(roll_no: absent_roll_nos, standard_id: standard_id, school_id: school_id).pluck(:id)
      end

      def set_result
        @result = {
          message: "SMS has been sent successfully"
        }
      end
    end
  end
end
