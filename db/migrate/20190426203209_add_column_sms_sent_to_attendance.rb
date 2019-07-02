class AddColumnSmsSentToAttendance < ActiveRecord::Migration[5.2]
  def change
    add_column :attendances, :sms_sent, :boolean
  end
end
