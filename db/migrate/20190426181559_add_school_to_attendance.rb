class AddSchoolToAttendance < ActiveRecord::Migration[5.2]
  def change
    add_reference :attendances, :school, foreign_key: true
  end
end
