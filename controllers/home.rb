class Site < Sinatra::Base
  FIELDS = %w{mc_gross mc_currency quantity payer_id payment_date first_name last_name txn_id payer_email item_number residence_country}.freeze
  PAYPAL_BASE = 'https://www.paypal.com'
  PAYPAL_PATH = '/cgi-bin/webscr'
  CMD = '_notify-synch'

  # TODO: EXTERNALIZE!
  IDENTITY_TOKEN = '5Pp5S7K_hhPPaTIQBrsJYiSKFlmN2jlXZ9yzPvV3_cDs0LsJDOmhLpgjAEe'
  MERCHANT_ID = 'KHGTN6Q5JVNV8'

  SUCCESS = 'SUCCESS'

  # TODO: EXTERNALIZE or to db
  # FIX: fix Ranong price
  PRICES = [-1, 1290, 1790, 3690].freeze
  ITEMS = [nil, :ranong, :ranong_andaman, :penang].freeze

  get '/' do
    slim :'home/index', locals: {merchant: MERCHANT_ID}
  end

  get '/payback' do
    begin
      tx = params[:tx]

      conn = Faraday.new(:url => PAYPAL_BASE) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end

      response = conn.post PAYPAL_PATH, {cmd: CMD, tx: tx, at: IDENTITY_TOKEN}
      body = response.body.split

      result = body.shift
      fail FailedPayment, :payment_gate_fail unless result == SUCCESS

      data = body.inject({}) do |acc, eq|
        key, value = eq.split '='
        acc[key.to_sym] = value if FIELDS.include? key
        acc
      end

      # TODO: if possible, move validations to model

      data[:item_number] = data[:item_number].to_i
      fail FailedPaymentForRefund, I18n.t('fails.no_such_item') unless (1..3).include? data[:item_number]

      fail FailedPaymentForRefund, I18n.t('fails.not_thb') unless data[:mc_currency] == 'THB'

      data[:mc_gross] = data[:mc_gross].to_f
      data[:quantity] = data[:quantity].to_i

      fail FailedPaymentForRefund, I18n.t('fails.gross_mismatch') unless data[:mc_gross] == data[:quantity] * PRICES[data[:item_number]]

      data[:payment_date] = URI.decode_www_form_component data[:payment_date]
      # "03:07:33 Apr 03, 2014 PDT" WTF is that?
      data[:payment_date] = Time.strptime data[:payment_date], "%H:%M:%S %b %e, %Y %Z"

      data[:payer_email] = URI.decode_www_form_component data[:payer_email]

      # TODO: check by txn_id to avoid duplicates
      order = Order.first_or_new({ txn_id: data[:txn_id]}, {
        gross: data[:mc_gross],
        currency: data[:mc_currency],
        quantity: data[:quantity],
        item: ITEMS[data[:item_number]],
        payer_id: data[:payer_id],
        payment_at: data[:payment_date],
        payer_first_name: data[:first_name],
        payer_last_name: data[:last_name],
        payer_email: data[:payer_email],
        residence_country: data[:residence_country],
        trip_date: cookies[:date],
        phone: cookies[:phone],
        leader: cookies[:name]
      })

      fail FailedPaymentForRefund, order.errors.inspect unless order.save

      # TODO: add residence_country instructions

      # TODO: send email receipt

      slim :'home/successful_payment', locals: { order: order}
    rescue FailedPaymentForRefund => e
      # TODO: store failed payment for later refund etc

      slim :'home/failed_payment_refund', locals: { text: e.message, order: order}
    rescue FailedPayment => e

      slim :'home/failed_payment', locals: { text: e.message }
    end
  end
end
