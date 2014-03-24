class Site < Sinatra::Base
  FIELDS = %w{mc_gross mc_currency quantity payer_id payment_date first_name last_name txn_id payer_email item_name item_number residence_country}.freeze
  PAYPAL_BASE = 'https://www.paypal.com'
  PAYPAL_PATH = '/cgi-bin/webscr'
  CMD = '_notify-synch'

  # TODO: EXTERNALIZE!
  IDENTITY_TOKEN = 'HHIchSgtCHHXoh5_LY1SKVZhd7le8mUP-Vl9hSetN5X5X0Ngn-eocaTY5XW'

  SUCCESS = "SUCCESS"

  get '/' do
    slim :'home/index'
  end

  get '/payback' do
    tx = params[:tx]

    conn = Faraday.new(:url => PAYPAL_BASE) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end

    response = conn.post PAYPAL_PATH, {cmd: CMD, tx: tx, at: IDENTITY_TOKEN}
    body = response.body.split

    result = body.shift
    return slim :'home/failed_payment' unless result == SUCCESS

    data = body.inject({}) do |acc, eq|
      key, value = eq.split "="
      acc[key.to_sym] = value if FIELDS.include? key
      acc
    end

    data[:item_name] = URI.decode_www_form_component data[:item_name]

    # TODO: add check
    # if data[:item_number] is not in the list

    # TODO: add check
    # if data[:mc_currency] is not "THB"

    data[:mc_gross] = data[:mc_gross].to_f
    data[:quantity] = data[:quantity].to_i

    # TODO: add check
    # if data[:mc_gross] != price for item * quantity

    data[:payment_date] = URI.decode_www_form_component data[:payment_date]
    data[:payer_email] = URI.decode_www_form_component data[:payer_email]

    # TODO: store

    # TODO: add residence_country instructions

    # TODO: send SMS and email

    slim :'home/successful_payment', locals: {
      name: [data[:first_name], data[:last_name]].join(' '),
      quantity: data[:quantity],
      item: data[:item_name]
    }
  end
end
