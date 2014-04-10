class Order
  include DataMapper::Resource
  property :id, Serial

  ## The following is coming from PayPal

  # "16R52395G74740448"
  property :txn_id, String, unique: true, required: true

  # 1290
  property :gross, Float, required: true

  # "THB"
  property :currency, String, required: true

  # 3
  property :quantity, Integer, required: true

  # 1 for Ranong, 2 for Ranong Andaman, 3 for Penang
  property :item, Enum[:ranong, :ranong_andaman, :penang], required: true

  # "XSR2NSLSMU6PQ"
  property :payer_id, String, required: true

  # Time
  property :payment_at, Time, required: true

  # "FILIPP"
  property :payer_first_name, String, required: true

  # "PIROZHKOV"
  property :payer_last_name, String, required: true

  # "pirjsuka@gmail.com"
  property :payer_email, String, required: true

  # "RU"
  property :residence_country, String, required: true

  ## This is coming from web form

  # Date 2014-03-13
  property :trip_date, Date, required: true

  # "0840888888"
  property :phone, String, required: true

  # "John Smith"
  property :leader, String, required: true

  property :pickup_lat, Float
  property :pickup_lng, Float

  property :created_at, DateTime

  def item_readable
    I18n.t item
  end
end
