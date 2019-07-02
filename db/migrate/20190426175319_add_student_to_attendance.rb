class AddStudentToAttendance < ActiveRecord::Migration[5.2]
  def change
    add_reference :attendances, :student, foreign_key: true
  end
end
