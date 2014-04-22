FactoryGirl.define do
  factory :route do
    title { Faker::Lorem.sentence[0..49] }

    factory :route_with_zero_vertex do
      vertex0 { FactoryGirl.create :vertex, route: self }
    end
  end
end
