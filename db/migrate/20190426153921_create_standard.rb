class CreateStandard < ActiveRecord::Migration[5.2]
  def change
    create_table :standards do |t|
      t.string :standard
      t.string :section
      t.time :start_time
      
      t.timestamps
    end
  end
end
