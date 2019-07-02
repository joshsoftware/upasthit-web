class AddSchoolToStaff < ActiveRecord::Migration[5.2]
  def change
    add_reference :staffs, :school, foreign_key: true
  end
end
