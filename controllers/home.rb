class Site < Sinatra::Base
  # TODO: EXTERNALIZE!
  MERCHANT_ID = 'KHGTN6Q5JVNV8'

  get '/' do
    slim :'home/index', locals: {merchant: MERCHANT_ID}
  end

  get '/payback' do
    begin
      txn_id = params[:tx]
      order = Order.first(txn_id: txn_id) || Order.load_paypal(txn_id, cookies)

      # TODO: add residence_country instructions
      # TODO: send email receipt

      session[:order_id] = order.id
      slim :'home/successful_payment', locals: { order: order}
    rescue FailedPaymentForRefund => e
      # TODO: store failed payment for later refund etc

      slim :'home/failed_payment_refund', locals: { text: e.message }
    rescue FailedPayment => e
      slim :'home/failed_payment', locals: { text: e.message }
    end
  end

  post '/pickup_location' do
    fail 'no order' unless session[:order_id]
    order = Order.get session[:order_id]
    fail 'not yours' unless params[:txn_id] == order.txn_id
    order.pickup_lat = params[:lat]
    order.pickup_lng = params[:lng]
    order.save
  end
end
