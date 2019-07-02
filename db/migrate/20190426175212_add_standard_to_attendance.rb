class AddStandardToAttendance < ActiveRecord::Migration[5.2]
  def change
    add_reference :attendances, :standard, foreign_key: true
  end
end
