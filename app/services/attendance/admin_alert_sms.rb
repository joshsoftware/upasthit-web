class Attendance::AdminAlertSms

  def self.call(standard_id)
    new(standard_id)
  end

  def initialize(standard_id)
    @standard = Standard.find(standard_id)
    @staffs = @standard&.staffs

    @staffs.collect do |staff|
      send_sms(staff.mobile_number)
    end
  end

  private

  def message
    I18n.locale = :'mr-IN'
    str = "#{I18n.translate('sms.admin_alert', standard: @standard.name, date: Date.today.strftime("%d-%m-%Y"))}\n"
    I18n.locale = :en
    str = "#{I18n.translate('sms.admin_alert', standard: @standard.name, date: Date.today.strftime("%d-%m-%Y"))}"
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
