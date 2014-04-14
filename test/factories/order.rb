FactoryGirl.define do
  factory :order do
    txn_id "16R52395G74740448"
    gross 1290
    currency "THB"
    quantity 1
    item :ranong
    payer_id "XSR2NSLSMU6PQ"
    payment_at Time.now
    payer_first_name { Faker::Name.first_name }
    payer_last_name { Faker::Name.last_name }
    payer_email { Faker::Internet.email }
    residence_country "RU"
    trip_date { Date.today + 2 }
    phone { Faker::PhoneNumber.phone_number }
    leader { Faker::Name.name }
    pickup_lat { Faker::Geolocation.lat }
    pickup_lng { Faker::Geolocation.lng }
  end
end
