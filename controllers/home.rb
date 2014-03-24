class Site < Sinatra::Base
  get '/' do
    slim :'home/index'
  end

  get '/payback' do
    puts params.inspect
  end

  put '/payback' do
    puts params.inspect
  end

  post '/payback' do
    puts params.inspect
  end



end
