class CreateStaff < ActiveRecord::Migration[5.2]
  def change
    create_table :staffs do |t|
      t.string :name
      t.string :mobile_number
      t.string :designation
      t.string :staff_id
 
      t.timestamps
    end
  end
end
