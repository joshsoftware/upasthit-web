class Api::AttendancesController < BaseController

  def create
    if params[:roll_nos] && params[:standard_id] && params[:date]
      create_attendance(params[:roll_nos], params[:standard_id], params[:date])
      render_success(data: {}, message: I18n.t('attendance.created'), status: :created)
    else
      render_error(message: I18n.t('attendance.failed'), status: :unprocessable_entity)
    end
  end

  def sms_callback
    if params[:sender] == Figaro.env.AUTHORISED_SENDER
      # ["Date:", "27.04.2019", "Std:", "5", "Section:", "C", "Roll_no:", "1", "2", "3"]
      data = params[:comments].split(/[',', ' ']/).map{|k| k.gsub("\n", "")}
      date = Date.parse(data[1])
      standard = data[3].to_i
      section = data[5]
      absent_roll_nos = data.split('Roll_no:')[1]
      standard_id = Standard.find_by(standard: standard, section: section).id
      create_attendance(absent_roll_nos, standard_id, date)
    else
      render_error(message: I18n.t('error.not_trusted_sender'), status: :unprocessable_entity)
    end
  end

  private

  def create_attendance(roll_nos, standard_id, date)
    Attendance::Create.new(roll_nos, standard_id, date).call
  end

end