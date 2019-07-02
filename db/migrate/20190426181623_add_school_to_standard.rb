class AddSchoolToStandard < ActiveRecord::Migration[5.2]
  def change
    add_reference :standards, :school, foreign_key: true
  end
end
