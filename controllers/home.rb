class Site < Sinatra::Base
  get '/' do
    slim :'home/index'
  end
end
