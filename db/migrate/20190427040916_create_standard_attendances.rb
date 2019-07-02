class CreateStandardAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :standard_attendances do |t|
      t.datetime :date
      t.integer :no_of_student_present 
      t.integer :no_of_absent_student
      t.boolean :attendance_marked, default: false
      t.timestamps
    end
  end
end
