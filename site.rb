require './common'
Bundler.require

require 'sinatra/contrib'
require 'sinatra/streaming'
require 'sinatra/content_for'
require 'sinatra/reloader' if development?

require 'i18n'
require 'i18n/backend/fallbacks'

configure do
  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
  I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
  I18n.backend.load_translations
end

Dir['controllers/*.rb'].each { |file| require File.join Dir.pwd, file }

# environment = development? ? :development : production? ? :production : :test
Bundler.require :development if development?

class Site < Sinatra::Base
  class InviteRequired < StandardError
    def code
      402
    end
  end

  register Sinatra::Contrib
  register Sinatra::Flash

  helpers Sinatra::ContentFor
  helpers Sinatra::Streaming

  use Rack::Session::Cookie
  # use Rack::Session::Moneta,
  #   store: Moneta.new(:DataMapper, setup: (ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db"))
  use Rack::Protection #, except: :session_hijacking

  use Rack::Locale

  register Sinatra::Can

  enable :logging

  set :root, File.dirname(__FILE__)

  [401, 403, 404, 500].each do |code|
    error(code) do
      slim :"errors/#{code}"
    end
  end

  configure :development do
    register Sinatra::Reloader
    also_reload './*.rb'
    also_reload './models/*.rb'
    also_reload './controllers/*.rb'
  end

  def current_identity
    @current_identity ||= Identity.get(session[:user_id]) if session[:user_id]
  end

  user do
    current_identity
  end

  helpers do
    def t token
      I18n.t token
    end
  end
end
