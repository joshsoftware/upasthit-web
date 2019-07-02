class DropStaff < ActiveRecord::Migration[5.2]
  def change
    drop_table :staffs
  end
end
