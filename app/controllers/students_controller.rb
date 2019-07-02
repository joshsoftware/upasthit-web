class StudentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:destroy]
  def index
    @standards = Standard.all
    @pagy, @records = pagy(Student.all)
    respond_to do |format|
      format.html
      format.json { render json: StudentDatatable.new(view_context) }
    end
  end

  def create
    service = Import::Students.new(params[:student][:file].tempfile, current_school.id)
    if service.call
      redirect_to students_path
    else
      @standards = Standard.all
      @pagy, @records = pagy(Student.all)
      @errors = service.errors.full_messages.collect(&:values).flatten
      render 'errors'
    end
  end

  def destroy
    student  = Student.where(id: params[:id]).first
    if student.present? 
      student.attendances.delete_all
      student.delete
    end
    
  end
end
