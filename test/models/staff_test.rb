# == Schema Information
#
# Table name: staffs
#
#  id                     :bigint(8)        not null, primary key
#  mobile_number          :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  registration_no        :string           not null
#  name                   :string
#  designation            :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  auth_token             :string
#  school_id              :bigint(8)
#  auth_token             :string
#

require 'test_helper'

class StaffTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
