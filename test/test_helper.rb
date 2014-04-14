require 'minitest/autorun'
require 'minitest/pride'

ENV['DATABASE_URL'] = "sqlite://#{Dir.pwd}/test.db"
require './common'
Bundler.require :test

class MiniTest::Unit::TestCase
  include FactoryGirl::Syntax::Methods
end

FactoryGirl.find_definitions

DataMapper.auto_migrate!

DatabaseCleaner.strategy = :truncation

class MiniTest::Spec
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end
