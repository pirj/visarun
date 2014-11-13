source 'https://rubygems.org'
ruby '2.1.2'

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

gem 'faraday'
gem 'em-http-request'

gem 'mail'

group :production do
  gem 'dm-postgres-adapter'
  gem 'pg'
end

group :development, :test do
  gem 'dm-sqlite-adapter'
  gem 'pry'
end

group :test do
  gem 'factory_girl'
  gem 'ffaker'
  gem 'database_cleaner'
end
