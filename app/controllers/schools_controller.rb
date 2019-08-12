# frozen_string_literal: true

class SchoolsController < ApplicationController
  def index
    current_staff.update(school: nil)
    @schools = School.all
  end

  def login
    current_staff.update(school: School.find(params[:school_id]))
    redirect_to root_path
  end
end
