source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Bootstrap and co
gem 'bootstrap'
gem 'popper_js'
gem 'jquery-rails'
gem 'font-awesome-rails'
gem 'globalize'
gem 'globalize-accessors'
gem 'jwt'
gem 'rack-cors', require: 'rack/cors'
gem 'mini_racer'
# Bootstrap form
gem "bootstrap_form", ">= 4.2.0"

# Haml
gem 'haml'

#Devise
gem 'devise'
gem 'jquery-datatables'


# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development
gem 'figaro'
gem 'redis'
gem 'sidekiq'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'smarter_csv', github: 'tilo/smarter_csv'
gem 'activerecord-import'
gem 'pagy'
gem "select2-rails"

gem 'whenever'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'pry'
  gem 'ffaker'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'annotate'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'database_cleaner', '~> 1.6.1'
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 3.5'
  gem 'shoulda'
  gem 'shoulda-matchers', '~> 3.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
