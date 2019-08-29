# frozen_string_literal: true

# == Schema Information
#
# Table name: sms_log
#
#  id                     :integer        not null, primary key
#  content                :string
#  is_delivered           :boolean          default false
#  message_token          :string
#  to                     :string
#  from                   :string
#  message_route          :string
#  receiver_id            :integer
#  receiver_type          :string
#  receiver_mobile        :string
#  sender_id              :integer
#  sender_type            :string
#  sender_mobile          :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class SmsLog < ApplicationRecord
  belongs_to :sender, polymorphic: true, optional: true
  belongs_to :receiver, polymorphic: true, optional: true
  enum attempted: %w[primary_no alternate_no admin_no]

  def self.generate(sms_log_hash={})
    # sender_mobile, receiver_mobile, content, to, message_token, student_id, from = "Server"
    sender_mobile = sms_log_hash["sender_mobile"]
    receiver_mobile = sms_log_hash["receiver_mobile"]
    content = sms_log_hash["content"]
    to = sms_log_hash["to"]
    message_token = sms_log_hash["message_token"]
    student_id = sms_log_hash["student_id"]
    from = sms_log_hash["from"]
    sender_id = from == "Staff" ? Staff.find_by(mobile_number: sender_mobile)&.id : "Server"
    receiver_id = if to == "Student"
                    student_id
                  else
                    to == "Staff" ? Staff.find_by(mobile_number: receiver_mobile)&.id : nil
                  end
    SmsLog.create(sender_mobile: sender_mobile, receiver_mobile: receiver_mobile, sender_id: sender_id, receiver_id: receiver_id, content: content, message_token: message_token)
  end

  def delivered
    update_column(:is_delivered, true)
  end
end
