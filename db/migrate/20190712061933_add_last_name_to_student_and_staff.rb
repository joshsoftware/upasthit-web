# frozen_string_literal: true

class AddLastNameToStudentAndStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :last_name, :string
    add_column :staffs, :last_name, :string
  end
end
