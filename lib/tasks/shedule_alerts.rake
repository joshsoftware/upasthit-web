namespace :shedule do
  desc 'shedule alerts'
  task alerts: :environment do
    Standard.find_each do |standard|
      wait_time = school.start_time + 2.hours

      AlertJob.set(wait_until: wait_time).perform_later(standard, Date.today)
    end
  end
end
