# frozen_string_literal: true

class AddPreferredLanguageToStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :preferred_language, :string, default: "en"
  end
end
