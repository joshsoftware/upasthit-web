class Api::StudentsController < BaseController
  def index
    school_id  = Standard.find(params[:standard_id]).school_id
    students  = Student.where(standard_id: params[:standard_id], school_id: school_id)
    standard_attendance  = StandardAttendance.where(standard_id: params[:standard_id], school_id: school_id, date: Date.today().strftime)
    status = standard_attendance.count != 0 ? standard_attendance.first.attendance_marked : false
    render_success( data: {  students: students.as_json(only: [:roll_no, :name, :gender, :standard_id],
                                                      methods: [:attendance_status]),
                            attendance_taken: status
                          }, status: 200 )
  end
end