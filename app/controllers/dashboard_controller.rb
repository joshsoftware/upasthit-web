class DashboardController < ApplicationController
  def index
    data = Attendance.where(school_id: 1).where('"date" > ?', Date.today.beginning_of_day).pluck(:present)
    result = data.uniq.map{|key| {key.to_s => (data.count(key)/data.size.to_f)*100}}
    @graph_data = [{name: "Present Students", y: result.map{|a| p a['true']}.compact.first},
                   {name: "Absent Students",  y: result.map{|a| p a['false']}.compact.first}].to_json.to_s
    respond_to do |format|
      format.html { render 'index'}
      format.json { render json: @graph_data }
    end
  end
end
