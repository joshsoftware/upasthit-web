# frozen_string_literal: true

class StaffDatatable
  delegate :params, :current_staff, to: :@view

  def initialize(view)
    @view = view
    @staffs = Staff.all
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
        staff.designation
      ]
    end
    arr
  end
end
