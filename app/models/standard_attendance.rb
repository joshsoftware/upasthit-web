class StandardAttendance < ApplicationRecord
  belongs_to :standard, class_name: "Standard", foreign_key: "standard_id"
  belongs_to :school, class_name: "School", foreign_key: "school_id"
end
