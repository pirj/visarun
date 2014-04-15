FactoryGirl.define do
  factory :order do
    txn_id { "16R52395G#{rand(1000000..99999999)}" }
    quantity { rand(1..3) }
    gross { 1290 * quantity }
    currency "THB"
    item :ranong
    payer_id "XSR2NSLSMU6PQ"
    payment_at Time.now
    payer_first_name { Faker::Name.first_name }
    payer_last_name { Faker::Name.last_name }
    payer_email { Faker::Internet.email }
    residence_country "RU"
    locale "RU"
    trip_date { Date.today + rand(2..10) }
    phone { "08#{rand(10000000..99999999)}" }
    leader { Faker::Name.name }
    pickup_lat { rand(7.87..7.94) }
    pickup_lng { rand(98.3..98.4) }
  end
end
