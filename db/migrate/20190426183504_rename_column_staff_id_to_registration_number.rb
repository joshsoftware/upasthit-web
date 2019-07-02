class RenameColumnStaffIdToRegistrationNumber < ActiveRecord::Migration[5.2]
  def change
    rename_column :staffs, :staff_id, :registration_no
  end
end
