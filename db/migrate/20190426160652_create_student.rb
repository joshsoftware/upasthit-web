class CreateStudent < ActiveRecord::Migration[5.2]
  def change
    create_table :students do |t|
      t.string :name
      t.string :registration_no
      t.integer :roll_no
      t.string :gender
      t.datetime :dob
      t.string :guardian_name
      t.string :guardian_mobile_no
      t.string :guardian_alternate_mobile_no
      t.timestamps
    end
  end
end
