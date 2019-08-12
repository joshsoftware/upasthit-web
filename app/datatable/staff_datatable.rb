# frozen_string_literal: true

class StaffDatatable
  delegate :params, :current_staff, to: :@view

  def initialize(view)
    @view = view
    @staffs = Staff.where(school: current_staff.school).kept.includes(:standards)
    @total_count = @staffs.count
  end

  def as_json(_options={})
    {
      sEcho:                params[:sEcho].to_i,
      aaData:               data,
      iTotalRecords:        @total_count,
      iTotalDisplayRecords: @total_count
    }
  end

  private

  def data
    arr = []
    @staffs.map do |staff|
      arr << [
        staff.full_name,
        staff.mobile_number,
        staff.designation,
        staff.standards.map(&:name).join(", "),
        staff.id.to_s
      ]
    end
    arr
  end
end
