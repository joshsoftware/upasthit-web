class AddStandardToStandardAttendance < ActiveRecord::Migration[5.2]
  def change
    add_reference :standard_attendances, :standard, foreign_key: true
  end
end
