# frozen_string_literal: true

class StaffsController < ApplicationController
  skip_before_action :verify_authenticity_token
  load_resource only: %i[edit show update]
  before_action :standards, except: %i[index]

  def standards
    @standards = Standard.where(school: current_school, staff_id: [@staff&.id, nil])
  end

  def new
    @staff = Staff.new
  end

  def create
    @staff = Staff.new(staff_params)
    @staff.school = current_school
    if @staff.save
      flash[:success] = t("staff.created")
      redirect_to staffs_path
    else
      flash[:error] = @staff.errors.full_messages.join
      render "new"
    end
  end

  def edit_password
    @staff = Staff.find(params[:staff_id])
  end

  def update_password
    @staff = Staff.find(params[:staff_id])
    redirect_to root_path if @staff.update_attributes(staff_params)
  end

  def update
    if @staff.update_attributes(staff_params)
      flash[:success] = t("staff.updated")
      redirect_to staff_path(@staff)
    else
      flash[:error] = @staff.errors.full_messages.join
      render "edit"
    end
  end

  def index
    staffs = Staff.where(school: current_school).kept
    @pagy, @records = pagy(staffs, items: staffs.size)
    respond_to do |format|
      format.html {}
      format.json { render json: StaffDatatable.new(view_context) }
    end
  end

  def import
    service = Import::Staff.new(params[:staff][:file].tempfile, current_school.id)
    if service.call
      redirect_to staffs_path
    else
      @pagy, @records = pagy(Staff.kept)
      @errors = service.errors.full_messages.map(&:values).flatten
      render "errors"
    end
  end

  def destroy
    staff = Staff.find_by(id: params[:id])
    return unless staff.present?

    flash[:success] = t("staff.deleted") if staff.discard
  end

  private

  def staff_params
    params.require(:staff).permit(:id, :mobile_number, :first_name, :last_name, :password, :password_confirmation,
                                  :designation, :school_id, :pin, :last_name, :preferred_language, standard_ids: [])
  end
end
