class AddColumnAuthTokenFieldInStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :auth_token, :string
  end
end
