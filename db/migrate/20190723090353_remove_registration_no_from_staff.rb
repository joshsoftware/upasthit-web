# frozen_string_literal: true

class RemoveRegistrationNoFromStaff < ActiveRecord::Migration[5.2]
  def change
    remove_column :staffs, :registration_no
  end
end
