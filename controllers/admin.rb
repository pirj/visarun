class Site < Sinatra::Base
  get '/8abc22fbd33a738170f40d43992336fd' do
    orders = Order.all order: [:trip_date.desc]
    slim :'admin/index', locals: {orders: orders}
  end
end
