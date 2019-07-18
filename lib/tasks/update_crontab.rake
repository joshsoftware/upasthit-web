# frozen_string_literal: true

namespace :update do
  desc "Update Crontab"
  task crontab: :environment do
    bundle exec "whenever --update-crontab"
  end
end
