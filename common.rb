require 'bundler'
Bundler.require

Dir['models/*.rb'].each { |file| require File.join Dir.pwd, file }

DataMapper.setup :default, ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.db"
DataMapper.finalize
# TODO: get rid of this
DataMapper.auto_upgrade!
#DataMapper::Logger.new(STDOUT, :debug)
