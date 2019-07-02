class Attendance::SendSms

  def self.call(attendance_ids)
    new(attendance_ids)
  end

  def initialize(attendance_ids)
    @attendance_ids = attendance_ids
    data = Attendance.includes(:student).where(id: attendance_ids).collect do |a|
     {
        mobile_number: a.student.guardian_mobile_no,
        alternate_mobile_number: a.student.guardian_alternate_mobile_no,
        name_en: a.student.name_en,
        name_mr_in: a.student.name_mr_in,
        attendance_id: a.id
      }
    end

    data.each do |student_data|
      @student_data = student_data
      response = send_sms(student_data[:mobile_number])
      response == "success" ? sms_sent_success : sms_sent_to_alternate_number
    end
  end

  private

  def message
    I18n.locale= :'mr-IN'
    str = "#{@student_data[:name_mr_in]}#{I18n.translate('sms.absent')}\n"
    I18n.locale= :en
    str = "#{@student_data[:name_en]}#{I18n.translate('sms.absent')}"
  end

  def sms_sent_success
    attendance = Attendance.find @student_data[:attendance_id]
    attendance.update(sms_sent: true)
  end

  def sms_sent_to_alternate_number
    response = send_sms(@student_data[:alternate_mobile_number])
    response == "success" ? sms_sent_success : notify_admin
  end

  def notify_admin
    attendance = Attendance.find @student_data[:attendance_id]
    attendance.update(sms_sent: false)
    "********Notify to Admin*********"
  end

  def send_sms(mobile_number)
    response = Net::HTTP.post_form(
                URI.parse(Figaro.env.TEXT_LOCAL_URL),
                apiKey: Figaro.env.MSG_API_KEY,
                sender: 'TXTLCL',
                message: message.squish,
                numbers: [mobile_number],
                receipt_url: ''
              )
    JSON.parse(response.body)['status']
  end

end