class CreateStudentTranslationTable < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        Student.create_translation_table! :name => :string
      end

      dir.down do
        Student.drop_translation_table!
      end
    end
  end
end
