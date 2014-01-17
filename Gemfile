source 'https://rubygems.org'

gem 'logging'

gem 'thin'
gem 'eventmachine'
gem 'sinatra'
gem 'sinatra-contrib', require: 'sinatra/contrib'
gem 'sinatra-flash', require: 'sinatra/flash'
gem 'sinatra-can', require: 'sinatra/can'
gem 'rack-protection'
gem 'rack-contrib'
gem 'i18n'
gem 'moneta', require: 'rack/session/moneta'
gem 'slim'

gem 'bcrypt-ruby', require: 'bcrypt'

gem 'dm-timestamps'
gem 'dm-validations'
gem 'dm-migrations'
gem 'dm-types'
gem 'dm-aggregates'

group :production do
  gem 'dm-postgres-adapter'
end

group :development do
  gem 'dm-sqlite-adapter'
  gem 'pry'
  gem 'pry-rescue'
end

group :test do
  gem 'factory_girl'
  gem 'ffaker'
  gem 'database_cleaner'
end
