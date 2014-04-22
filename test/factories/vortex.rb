FactoryGirl.define do
  factory :vertex do
    lat { rand(7.87..7.94) }
    lng { rand(98.3..98.4) }

    caption { Faker::Lorem.sentence[0..49] }
    route

    factory :vertex_chain do
      previous { FactoryGirl.create :vertex }
    end
  end
end
