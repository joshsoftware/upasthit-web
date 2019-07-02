class AddStandardToStudent < ActiveRecord::Migration[5.2]
  def change
    add_reference :students, :standard, foreign_key: true
  end
end
