class CreateSmsLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :sms_logs do |t|
      t.string :content
      t.boolean :is_delivered, index: true, default: false
      t.string :message_token, index: true
      t.string :sender_type, index: true
      t.string :receiver_type, index: true
      t.integer :sender_id, index: true
      t.integer :receiver_id, index: true
      t.string :sender_mobile, index: true
      t.string :receiver_mobile, index: true

      t.timestamps
    end
  end
end
