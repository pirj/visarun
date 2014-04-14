class Order
  include DataMapper::Resource
  property :id, Serial

  ## The following is coming from PayPal
  property :txn_id, String, unique: true, required: true # "16R52395G74740448"
  property :gross, Float, required: true # 1290
  property :currency, String, required: true # "THB"
  property :quantity, Integer, required: true # 3
  property :item, Enum[:ranong, :ranong_andaman, :penang], required: true # 1 for Ranong, 2 for Ranong Andaman, 3 for Penang
  property :payer_id, String, required: true # "XSR2NSLSMU6PQ"
  property :payment_at, Time, required: true # Time
  property :payer_first_name, String, required: true # "FILIPP"
  property :payer_last_name, String, required: true # "PIROZHKOV"
  property :payer_email, String, required: true # "pirjsuka@gmail.com"
  property :residence_country, String, required: true # "RU"

  ## This is coming from web form
  property :trip_date, Date, required: true # Date 2014-03-13
  property :phone, String, required: true # "0840888888"
  property :leader, String, required: true # "John Smith"

  ## User chooses pickip point
  property :pickup_lat, Float
  property :pickup_lng, Float
# TODO: fix these once printed by admin

  property :created_at, DateTime

  def item_readable
    I18n.t item
  end

  PAYPAL_FIELDS = %w{mc_gross mc_currency quantity payer_id payment_date first_name last_name txn_id payer_email item_number residence_country}.freeze
  PAYPAL_BASE = 'https://www.paypal.com'.freeze
  PAYPAL_PATH = '/cgi-bin/webscr'.freeze
  CMD = '_notify-synch'.freeze

  PAYPAL_TIME_FORMAT = "%H:%M:%S %b %e, %Y %Z".freeze # "03:07:33 Apr 03, 2014 PDT" WTF is that?

  SUCCESS = 'SUCCESS'.freeze
  THB = 'THB'.freeze

  # TODO: EXTERNALIZE!
  IDENTITY_TOKEN = '5Pp5S7K_hhPPaTIQBrsJYiSKFlmN2jlXZ9yzPvV3_cDs0LsJDOmhLpgjAEe'.freeze

  # TODO: EXTERNALIZE or to db
  PRICES = [-1, 1290, 1790, 3690].freeze
  PAYPAL_ITEMS = [nil, :ranong, :ranong_andaman, :penang].freeze

  def self.load_paypal txn_id, cookies
    conn = Faraday.new(:url => PAYPAL_BASE) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end

    response = conn.post PAYPAL_PATH, {cmd: CMD, tx: txn_id, at: IDENTITY_TOKEN}
    parse_paypal response.body.split, cookies
  end

  def self.parse_paypal body, cookies
    result = body.shift
    fail FailedPayment, :payment_gate_fail unless result == SUCCESS

    data = body.inject({}) do |acc, eq|
      key, value = eq.split '='
      acc[key.to_sym] = value if PAYPAL_FIELDS.include? key
      acc
    end

    data[:item_number] = data[:item_number].to_i
    fail FailedPaymentForRefund, I18n.t('fails.no_such_item') unless (1..3).include? data[:item_number]

    fail FailedPaymentForRefund, I18n.t('fails.not_thb') unless data[:mc_currency] == THB

    data[:mc_gross] = data[:mc_gross].to_f
    data[:quantity] = data[:quantity].to_i

    fail FailedPaymentForRefund, I18n.t('fails.gross_mismatch') unless data[:mc_gross] == data[:quantity] * PRICES[data[:item_number]]

    data[:payment_date] = URI.decode_www_form_component data[:payment_date]
    data[:payment_date] = Time.strptime data[:payment_date], PAYPAL_TIME_FORMAT

    data[:payer_email] = URI.decode_www_form_component data[:payer_email]

    order = Order.new({
      txn_id: data[:txn_id],
      gross: data[:mc_gross],
      currency: data[:mc_currency],
      quantity: data[:quantity],
      item: PAYPAL_ITEMS[data[:item_number]],
      payer_id: data[:payer_id],
      payment_at: data[:payment_date],
      payer_first_name: data[:first_name],
      payer_last_name: data[:last_name],
      payer_email: data[:payer_email],
      residence_country: data[:residence_country],
      trip_date: Date.strptime(cookies[:date], I18n.t("date.formats.default")),
      phone: cookies[:phone],
      leader: cookies[:name]
    })

    fail FailedPaymentForRefund, order.errors.inspect unless order.save

    order
  rescue FailedPaymentForRefund => e
    failed = FailedOrder.create({
      txn_id: data[:txn_id],
      gross: data[:mc_gross],
      currency: data[:mc_currency],

      payer_id: data[:payer_id],
      payment_at: data[:payment_date],

      payer_first_name: data[:first_name],
      payer_last_name: data[:last_name],
      payer_email: data[:payer_email]
    })

    fail FailedPaymentForRefund, e.message
  end
end
