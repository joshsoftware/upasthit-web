# frozen_string_literal: true

class AddStaffIdToStandard < ActiveRecord::Migration[5.2]
  def change
    add_reference :standards, :staff, foreign_key: true
  end
end
