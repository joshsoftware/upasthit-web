class CreateSchools < ActiveRecord::Migration[5.2]
  def change
    create_table :schools do |t|
      t.string :name, null: false
      t.string :address
      t.string :school_code, null: false, unique: true
      t.time :start_time
      t.time :close_time

      t.timestamps
    end
  end
end
