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
  audited
  include Discard::Model
  include Tokenable
  include Authenticable
  devise :trackable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  def self.designations
    %w[Admin ClassTeacher SuperAdmin]
  end

  devise :database_authenticatable, :recoverable, :rememberable
  belongs_to :school, optional: true
  has_many :standards

  validates_presence_of :school_id, unless: :super_admin?
  validates :pin, length: {is: 4}
  validates_presence_of :mobile_number
  validates_uniqueness_of :mobile_number, conditions: -> { where(discarded_at: nil) }
  validates :designation, inclusion: {in: Staff.designations}

  delegate :admin?, :class_teacher?, :super_admin?, to: :designation_enquiry
  validates :preferred_language, inclusion: {in: %w[en mr-IN hi-IN]}

  def designation_enquiry
    designation.to_s.underscore.inquiry
  end

  def full_name
    first_name + " " + last_name
  end

  def standard_ids
    super.map(&:to_json)
  end

  def in_json
    as_json(
      except:  %i[created_at updated_at auth_token school_id],
      methods: :standard_ids
    )
  end
end
