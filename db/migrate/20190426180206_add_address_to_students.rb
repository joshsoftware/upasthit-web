class AddAddressToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :address, :string
  end
end
