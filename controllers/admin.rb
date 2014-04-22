class Site < Sinatra::Base
  ADMIN_ENTRY = "8abc22fbd33a738170f40d43992336fd".freeze

  def data
    @orders = Order.all :trip_date.gte => Date.today, :order => [:trip_date.desc]
    @failed_orders = FailedOrder.all refunded: false, order: [:payment_at.desc]
    @tomorrow_all = {
      ranong: Order.all(:trip_date => (Date.today + 1), item: :ranong, :order => [:trip_date.desc]),
      ranong_andaman: Order.all(:trip_date => (Date.today + 1), item: :ranong_andaman, :order => [:trip_date.desc]),
      penang: Order.all(:trip_date => (Date.today + 1), item: :penang, :order => [:trip_date.desc])
    }
  end

  get "/#{ADMIN_ENTRY}" do
    data
    slim :'admin/index'
  end

  get "/#{ADMIN_ENTRY}/11" do
    EM.defer do
      email = 'pirjsuka@gmail.com'

      Mail.new do
        from     'visarun.co.th@gmail.com'
        to       email
        subject  'Test'

        html_part do
          content_type 'text/html; charset=UTF-8'
          body     "Test test"
        end
      end.deliver
    end
    body "sent!"
  end

  get "/#{ADMIN_ENTRY}/orders" do
    data
    slim :'admin/orders'
  end

  get "/#{ADMIN_ENTRY}/failed_orders" do
    data
    slim :'admin/failed_orders'
  end

  get "/#{ADMIN_ENTRY}/tomorrow/:direction" do
    data
    @tomorrow = @tomorrow_all[params[:direction].to_sym]
    slim :'admin/tomorrow'
  end

  get "/#{ADMIN_ENTRY}/pickup" do
    data
    slim :'admin/pickup'
  end

  post "/#{ADMIN_ENTRY}/pickup/add" do
    STDOUT.puts params.inspect

  end

  post "/#{ADMIN_ENTRY}/pickup/update" do
    STDOUT.puts params.inspect

  end
end
