# frozen_string_literal: true

class StandardsController < ApplicationController
  load_resource only: %i[edit show update]
  before_action :staffs

  def staffs
    @staffs = Staff.where(school_id: current_school.id, discarded_at: nil)
  end

  def new
    @standard = Standard.new
  end

  def create
    @standard = Standard.new(standard_params)
    @standard.school = current_school
    if @standard.save
      flash[:success] = t("standard.created")
      redirect_to standards_path
    else
      flash[:error] = @standard.errors.full_messages.join
      render "new"
    end
  end

  def update
    if @standard.update_attributes(standard_params)
      flash[:success] = t("standard.updated")
      redirect_to standards_path
    else
      flash[:error] = @standard.errors.full_messages.join
      render "edit"
    end
  end

  def index
    standards = Standard.where(school: current_school).includes(:students)
    @pagy, @records = pagy(standards, items: standards.size)
  end

  def import
    service = Import::Standards.new(params[:standard][:file].tempfile, current_school.id)
    if service.call
      redirect_to standards_path
    else
      @pagy, @records = pagy(Standard.all)
      @errors = service.errors.full_messages.map(&:values).flatten
      render "errors"
    end
  end

  private

  def standard_params
    params.require(:standard).permit(:id, :standard, :section, :staff_id)
  end
end
