class StaffsController < ApplicationController
  def index
    respond_to do |format|
      format.html {  }
      format.json { render json: StaffDatatable.new(view_context)}
    end
    @pagy, @records = pagy(Staff.all)
  end

  def create
    service = Import::Staff.new(params[:staff][:file].tempfile, current_school.id)
    if service.call
      redirect_to staffs_path
    else
      @pagy, @records = pagy(Staff.all)
      @errors = service.errors.full_messages.collect(&:values).flatten
      render 'errors'
    end
  end
end
