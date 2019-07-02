namespace :student do
  desc 'Import students'
  task import: :environment do
    outcome = Import::Students
              .new(Rails.root.join('public', 'students.csv').to_s)
              .run

    if outcome[:errors].any?
      puts "Errors #{outcome[:errors]}"
      puts outcome[:errors].keys
    else
      puts "Success"
    end
  end
end
