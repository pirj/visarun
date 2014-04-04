require 'bundler'
Bundler.require

Dir['models/*.rb'].each { |file| require File.join Dir.pwd, file }

DataMapper.setup :default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db"
DataMapper.finalize
# TODO: get rid of this
DataMapper.auto_upgrade!

# TODO: why it doesn't work?
#DataMapper::Logger.new(STDOUT, :debug)

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
I18n.backend.load_translations
I18n.default_locale = :'en-US'
