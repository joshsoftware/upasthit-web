# frozen_string_literal: true

class CreateAttendances < ActiveRecord::Migration[5.2]
  def change
    create_table :attendances do |t|
      t.datetime :date
      t.boolean :present

      t.timestamps
    end
  end
end
