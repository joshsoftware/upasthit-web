# frozen_string_literal: true

class ModifyFieldsInStudentsTranslationTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :student_translations, :name, :first_name
    reversible do |dir|
      dir.up do
        Student.add_translation_fields! last_name: :string
      end

      dir.down do
        remove_column :student_translations, :last_name
      end
    end
  end
end
