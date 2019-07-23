# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

school1 = School.find_or_create_by(name: "Delhi Public School", school_code: "1000",
                                   contact_number: "98792873823", email: "dps@gmail.org")
school2 = School.find_or_create_by(name: "Agra Public School", school_code: "1001",
                                   contact_number: "98792873822", email: "aps@gmail.org")

# School.find_each do |school|
#   SchoolTiming.days.keys.each do |day|
#     SchoolTiming.find_or_create_by(start_time: "08:00:00", close_time: "14:00:00", school_id: school.id,
#      day: day, reminder_time: "10:00:00")
#   end
# end

staff1 = Staff.find_or_create_by(mobile_number: "9876543210", designation: "Admin", school_id: school1.id,
                 pin: "1221", first_name: "Suhana", last_name: "Sharma") do |staff|
  staff.password = "12345678"
  staff.password_confirmation = "12345678"
end
staff2 = Staff.find_or_create_by(mobile_number: "9998823112", designation: "ClassTeacher", school_id: school1.id,
                pin: "1441", first_name: "Aman", last_name: "Singh") do |staff|
  staff.password = "12345678"
  staff.password_confirmation = "12345678"
end
staff3 = Staff.find_or_create_by(mobile_number: "9998823122", designation: "ClassTeacher", school_id: school2.id,
                pin: "1551", first_name: "Priya", last_name: "Chopra") do |staff|
  staff.password = "12345678"
  staff.password_confirmation = "12345678"
end
standard1 = Standard.find_or_create_by!(standard: "2", section: "A", school_id: school1.id)
standard2 = Standard.find_or_create_by!(standard: "2", section: "B", school_id: school1.id)
standard3 = Standard.find_or_create_by!(standard: "3", section: "A", school_id: school1.id)

standard1.staffs << staff1
standard2.staffs << staff2
standard3.staffs << staff1

standard4 = Standard.find_or_create_by!(standard: "4", section: "A", school_id: school2.id)

standard4.staffs << staff3
standard4.staffs << staff3

Student.find_or_create_by(first_name: "Amit", last_name: "Kumar", registration_no: "100", roll_no: "1", dob: Time.zone.parse("01-11-1996"),
                         guardian_name: "Ashok Kumar", preferred_language: "en", guardian_mobile_no: "7798845221",
                         school_id: school1.id, standard_id: standard1.id, gender: "male")
Student.find_or_create_by!(first_name: "Preethi", last_name: "Reddy", registration_no: "101", roll_no: "2", dob: Time.zone.parse("02-11-1996"),
                         guardian_name: "Ashok Reddy", preferred_language: "en", guardian_mobile_no: "7798845221",
                         school_id: school1.id, standard_id: standard1.id, gender: "female")
Student.find_or_create_by!(first_name: "Kabir", last_name: "Singh", registration_no: "108", roll_no: "3", dob: Time.zone.parse("21-11-1996"),
                         guardian_name: "Ashok Singh", preferred_language: "en", guardian_mobile_no: "7798845221",
                         school_id: school2.id, standard_id: standard4.id, gender: "male")
Attendance.find_or_create_by(present: true, date: DateTime.now - 1.month, student_id: Student.first.id,
                            standard_id: Student.first.standard_id, school_id: Student.first.school_id)
Attendance.find_or_create_by(present: true, date: DateTime.now - 2.month, student_id: Student.first.id,
                            standard_id: Student.first.standard_id, school_id: Student.first.school_id)
Attendance.find_or_create_by(present: true, date: DateTime.now - 1.month, student_id: Student.second.id,
                            standard_id: Student.second.standard_id, school_id: Student.second.school_id)
Attendance.find_or_create_by(present: true, date: DateTime.now - 5.days, student_id: Student.first.id,
                            standard_id: Student.first.standard_id, school_id: Student.first.school_id)
Attendance.find_or_create_by(present: true, date: DateTime.now - 2.days, student_id: Student.first.id,
                            standard_id: Student.first.standard_id, school_id: Student.first.school_id)
p "Seed completed sucessfully"
