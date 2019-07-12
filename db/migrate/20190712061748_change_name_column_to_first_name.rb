# frozen_string_literal: true

class ChangeNameColumnToFirstName < ActiveRecord::Migration[5.2]
  def change
    rename_column :students, :name, :first_name
    rename_column :staffs, :name, :first_name
  end
end
