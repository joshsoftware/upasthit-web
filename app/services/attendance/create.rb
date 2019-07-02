# Responsible for importing item master vessel tags
class Attendance::Create
  Sidekiq::Extensions.enable_delay!
  def initialize(absent_roll_numbers, standard_id, date)
    @standard = Standard.find standard_id
    @school = @standard.school
    @absent_roll_numbers = absent_roll_numbers
    @date = date
  end

  def call
    students_ids = Student.where(standard_id: @standard.id, school_id: @school.id).pluck(:id)
    absent_student_ids = Student.where(roll_no: @absent_roll_numbers, standard_id: @standard.id, school_id: @school.id).pluck(:id)
    # students_attendance_taken_ids = Attendance.where(date: @date, standard_id: @standard_id, school_id: @school.id).pluck(:student_id)
    # absent_student_ids = absent_student_ids - students_attendance_taken_ids
    attendances = students_ids.collect do |student_id|
                    Attendance.new(
                      present: !(absent_student_ids.include?(student_id)),
                      date: @date,
                      school_id: @school.id,
                      standard_id: @standard.id,
                      student_id: student_id
                    )
                  end
    imported_data = Attendance.import attendances
    if imported_data
      today_attendance_count = Attendance.where(date: @date, standard_id: @standard.id, school_id: @school.id).count
      absent_student_attendance_ids = Attendance.where(date: @date, present: false, standard_id: @standard.id, school_id: @school.id).pluck(:id)
      Attendance::SendSms.delay.call(absent_student_attendance_ids)
      StandardAttendance.create(date: @date,
                                school_id: @school.id,
                                standard_id: @standard.id,
                                attendance_marked: true,
                                no_of_student_present: today_attendance_count - absent_student_attendance_ids.count,
                                no_of_absent_student: absent_student_attendance_ids.count
                                )
    end
  end
end
