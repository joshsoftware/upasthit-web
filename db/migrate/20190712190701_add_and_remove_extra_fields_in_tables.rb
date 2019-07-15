# frozen_string_literal: true

class AddAndRemoveExtraFieldsInTables < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :email, :string
    add_column :schools, :contact_number, :string
    remove_column :schools, :start_time
    remove_column :schools, :close_time
    add_column :students, :vehicle_number, :string
    remove_column :standards, :start_time
  end
end
