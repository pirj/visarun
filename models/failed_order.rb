class FailedOrder
  include DataMapper::Resource
  property :id, Serial

  property :txn_id, String, unique: true, required: true # "16R52395G74740448"
  property :gross, Float, required: true # 1290
  property :currency, String, required: true # "THB"

  property :payer_id, String, required: true # "XSR2NSLSMU6PQ"
  property :payment_at, Time, required: true # Time

  property :payer_first_name, String, required: true # "FILIPP"
  property :payer_last_name, String, required: true # "PIROZHKOV"
  property :payer_email, String, required: true # "pirjsuka@gmail.com"

  property :refunded, Boolean, default: false
end
