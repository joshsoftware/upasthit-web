class AddSchoolToStandardAttendance < ActiveRecord::Migration[5.2]
  def change
    add_reference :standard_attendances, :school, foreign_key: true
  end
end
