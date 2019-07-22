# frozen_string_literal: true

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

class Staff < ApplicationRecord
  include Tokenable
  include Authenticable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  def self.designations
    %w[Admin ClassTeacher]
  end

  devise :database_authenticatable, :recoverable, :rememberable
  belongs_to :school, class_name: "School", foreign_key: "school_id"
  has_many :standards, through: :st
  has_and_belongs_to_many :standards, join_table: :staffs_standards

  validates :pin, length: {is: 4}
  validates :mobile_number, :registration_no, uniqueness: true
  validates :designation, inclusion: {in: Staff.designations}

  delegate :admin?, :class_teacher?, to: :designation_enquiry
  validates :preferred_language, inclusion: {in: %w[en mr-IN hi-IN]}

  def designation_enquiry
    designation.to_s.underscore.inquiry
  end

  def standard_ids
    super.map(&:to_json)
  end

  def full_name
    first_name + " " + last_name
  end

  def in_json
    as_json(
      except:  %i[created_at updated_at auth_token school_id],
      methods: :standard_ids
    )
  end
end
