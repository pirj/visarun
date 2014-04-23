class Site < Sinatra::Base
  # TODO: EXTERNALIZE!
  MERCHANT_ID = 'KHGTN6Q5JVNV8'

  SMSC_URL = 'https://smsc.ru'.freeze
  SMSC_PATH = '/sys/send.php'.freeze

  # TODO: externalize
  SMSC_LOGIN = 'visarun'.freeze
  SMSC_PASS_MD5 = 'e572b046b9d8b058e2a84e40c10bb22c'.freeze

  get '/' do
    slim :'home/index', locals: {merchant: MERCHANT_ID}
  end

  get '/payback' do
    begin
      txn_id = params[:tx]
      order = Order.first(txn_id: txn_id)

      unless order
        order = Order.load_paypal(txn_id, cookies)

        # TODO: check if locale remains intact in EM.defer block
        EM.defer do
          html = slim(:'home/receipt', locals: {order: order})

          Mail.new do
            from 'visarun.co.th@gmail.com'
            to order.payer_email
            subject I18n.t('success.payment_received')

            html_part do
              content_type 'text/html; charset=UTF-8'
              # TODO: add residence_country instructions
              body html
            end
          end.deliver
        end

        EM.defer do
          conn = Faraday.new(:url => SMSC_URL) do |faraday|
            faraday.request :url_encoded
            faraday.adapter :em_http
          end

          # remind 12 hours before trip
          timestamp = order.trip_date.to_time.to_i - 43200

          # TODO: support international phones too
          phone = "+66" + order.phone.gsub(/^0/, '')
          resp = conn.post SMSC_PATH, {
            login: SMSC_LOGIN,
            psw: SMSC_PASS_MD5,
            phones: phone,
            mes: I18n.t('reminder'),
            charset: 'utf-8',
            time: "0#{timestamp}" # Timestamp
          }
        end
      end

      @routes = Route.all

      session[:order_id] = order.id
      slim :'home/successful_payment', locals: { order: order}
    rescue FailedPaymentForRefund => e
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
