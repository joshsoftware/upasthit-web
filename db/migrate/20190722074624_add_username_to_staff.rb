# frozen_string_literal: true

class AddUsernameToStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :user_name, :string
  end
end
