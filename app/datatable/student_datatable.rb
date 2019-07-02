class StudentDatatable
  delegate :params, :current_user, to: :@view

  def initialize(view)
    @view = view
    if @view.params['standard_id'].present?
      @students =Student.where(standard_id: @view.params['standard_id'])
    else
      @students = Student.all
    end
    @total_count = @students.count
  end

  def as_json(options = {})
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
    @students.map do |student|
      arr <<  [
        student.registration_no,
        student.roll_no,
        student.name,
        student.guardian_name,
        student.guardian_mobile_no,
        student.id.to_s
      ]
    end
    arr
  end
end
