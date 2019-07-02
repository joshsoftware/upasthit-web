class StandardsController < ApplicationController
  def index
    @pagy, @records = pagy(Standard.all)
  end

  def create
    service = Import::Standards.new(params[:standard][:file].tempfile, current_school.id)
    if service.call
      redirect_to standards_path
    else
      @pagy, @records = pagy(Standard.all)
      @errors = service.errors.full_messages.collect(&:values).flatten
      render 'errors'
    end
  end
end
