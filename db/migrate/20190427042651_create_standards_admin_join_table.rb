class CreateStandardsAdminJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :standards, :staffs do |t|
      t.index [:standard_id, :staff_id]
      t.index [:staff_id, :standard_id]
    end
  end
end
