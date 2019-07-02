# == Schema Information
#
# Table name: schools
#
#  id          :bigint(8)        not null, primary key
#  name        :string           not null
#  address     :string
#  school_code :string           not null
#  start_time  :time
#  close_time  :time
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
