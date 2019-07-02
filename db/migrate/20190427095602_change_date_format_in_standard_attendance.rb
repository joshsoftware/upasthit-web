class ChangeDateFormatInStandardAttendance < ActiveRecord::Migration[5.2]
  def up
    change_column :standard_attendances, :date, :date
   end
 
   def down
    change_column :standard_attendances, :date, :datetime
   end
end
