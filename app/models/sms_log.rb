# frozen_string_literal: true

# == Schema Information
#
# Table name: sms_log
#
#  id                     :integer
#  content                :string - Message Content
#  status                 :enum - message delivery status
#  message_token          :string - Pinnacle token - used for message delivery
#  receiver_id            :integer - if Staff or student else nil
#  receiver_type          :string - Staff, Student, Server
#  receiver_mobile        :string - if present else nil
#  sender_id              :integer - Staff id else nil
#  sender_type            :string - Staff, Server else nil
#  sender_mobile          :string - Staff's else nil
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  other_info             :string

class SmsLog < ApplicationRecord
  belongs_to :sender, polymorphic: true, optional: true
  belongs_to :receiver, polymorphic: true, optional: true
  enum number_type: %w[primary_no alternate_no admin_no]
  enum status: %w[sending delivered failed pending failed-dnd]

  def self.generate(sms_log_hash={})
    sender_type = sms_log_hash[:sender_type] || "Server"
    receiver_type = sms_log_hash[:receiver_type] || "Server"
    sender_id = sms_log_hash[:sender_type] == "Staff" ? Staff.find_by(mobile_number: sender_mobile)&.id : "Server"
    receiver_id = if receiver_type == "Parent"
                    Attendance.find_by(id: sms_log_hash.dig(:other_info, :attendance_id))&.student_id
                  else
                    receiver_type == "Staff" ? Staff.find_by(mobile_number: sms_log_hash[:receiver_mobile])&.id : nil
                  end
    SmsLog.create(
                  sender_mobile: sms_log_hash[:sender_mobile],
                  receiver_mobile: sms_log_hash[:receiver_mobile],
                  sender_id: sender_id,
                  receiver_id: receiver_id,
                  content: sms_log_hash[:content],
                  message_token: sms_log_hash[:message_token],
                  number_type: sms_log_hash[:number_type] || "primary_no",
                  status: "sending",
                  sender_type: sender_type,
                  receiver_type: receiver_type,
                  other_info: sms_log_hash[:other_info],
                 )
  end
end
