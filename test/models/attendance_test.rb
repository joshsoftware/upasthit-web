# == Schema Information
#
# Table name: attendances
#
#  id          :bigint(8)        not null, primary key
#  date        :datetime
#  present     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  standard_id :bigint(8)
#  student_id  :bigint(8)
#  school_id   :bigint(8)
#  sms_sent    :boolean
#

require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
