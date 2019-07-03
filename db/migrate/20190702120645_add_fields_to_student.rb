# frozen_string_literal: true

class AddFieldsToStudent < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :driver_name, :string
    add_column :students, :driver_number, :string
    add_column :students, :preferred_language, :string
  end
end
