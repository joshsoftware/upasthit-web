# frozen_string_literal: true

# Responsible for importing item master vessel tags
module Api
  module V1
    module Attendance
      class CreateService
        include ActiveModel::Validations
        validates :school_code, :date, :standard, presence: true
        validate :validate_school_code
        validate :validate_standard_with_section
        validate :validate_date

        attr_reader :params, :result

        def initialize(params={})
          @params = params || {}
        end

        def create
          return false unless valid?

          mark_attendance &&
          send_sms(absent_student_attendance_ids) &&
          set_result
        end

        private

        def mark_attendance
          student_ids ||= @standard.students.pluck(:id)
          @attendances ||= student_ids.map do |student_id|
            ::Attendance.where(
              date:        date,
              school_id:   school_id,
              standard_id: standard_id,
              student_id:  student_id
            ).first_or_create.tap do |attendance|
              attendance.update_attribute(:present, !absent_student_ids.include?(student_id))
            end
          end
          mark_standard_attendance
        end

        def absent_student_attendance_ids
          @absent_student_attendance_ids ||= @attendances.select {|attendance| absent_student_ids.include?(attendance.student.id) }.map(&:id)
        end

        def mark_standard_attendance
          StandardAttendance.where(date: date, school_id: school_id,
                                   standard_id: standard_id).first_or_create.tap do |standard_attendance|
            standard_attendance.update_attributes(attendance_marked:     true,
                                                  no_of_student_present: present_student_count,
                                                  no_of_absent_student:  present_student_count(false))
          end
        end

        def send_sms(absent_student_attendance_ids)
          return true unless absent_student_attendance_ids.present?

          NotifyParentJob.perform_later(absent_student_attendance_ids)
        end

        def present_student_count(present=true)
          ::Attendance.where(date: date, school_id: school_id, standard_id: standard_id,
                             present: present).distinct.count(:student_id)
        end

        def school_code
          params[:school_code]
        end

        def date
          Date.parse(params[:date]).to_s
        end

        def standard
          params[:standard]
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
          @standard ||= Standard.includes(:students).find_by(standard: standard, school_id: school_id, section: section)
          return true if @standard

          errors.add(:base, "Invalid Standard Id")
          false
        end

        def validate_date
          Date.parse(date)
        rescue StandardError
          nil
        end

        def standard_id
          @standard_id ||= @standard.id
        end

        def school_id
          @school_id ||= School.find_by(school_code: school_code)&.id
        end

        def absent_student_ids
          return [] unless absent_roll_nos.present?

          @absent_student_ids ||= Student.where(roll_no: absent_roll_nos, standard_id: standard_id, school_id: school_id).pluck(:id)
        end

        def set_result
          @result = {
            message:        "Attendance marked sucessfully",
            attendance_ids: @attendances.pluck(:id)
          }
        end
      end
    end
  end
end
