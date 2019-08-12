# frozen_string_literal: true

class StudentsController < ApplicationController
  load_resource only: %i[edit show update]
  before_action :standards

  def standards
    @standards = Standard.where(school: current_school)
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    @student.school = current_school
    if @student.save
      flash[:success] = t("students.created")
      redirect_to students_path
    else
      flash[:error] = @student.errors.full_messages.join
      render "new"
    end
  end

  def index
    students = Student.where(school: current_school).kept
    @pagy, @records = pagy(students, items: students.size)
    respond_to do |format|
      format.html
      format.json { render json: StudentDatatable.new(view_context) }
    end
  end

  def update
    if @student.update_attributes(student_params)
      flash[:success] = t("students.updated")
      redirect_to student_path(@student)
    else
      flash[:error] = @student.errors.full_messages.join
      render "edit"
    end
  end

  def import
    service = Import::Students.new(params[:student][:file].tempfile, current_school.id)
    if service.call
      redirect_to students_path
    else
      @standards = Standard.all
      @pagy, @records = pagy(Student.where(school: current_school).kept)
      @errors = service.errors.full_messages.map(&:values).flatten
      render "errors"
    end
  end

  def destroy
    student = Student.where(id: params[:id]).first
    return unless student.present?

    flash[:success] = t("students.deleted") if student.discard
  end

  private

  def student_params
    params.require(:student).permit(:id, :first_name, :registration_no, :roll_no, :gender,
                                    :dob, :guardian_name, :guardian_mobile_no, :guardian_alternate_mobile_no,
                                    :address, :driver_name, :driver_number, :preferred_language, :last_name,
                                    :vehicle_number, :standard_id)
  end
end
