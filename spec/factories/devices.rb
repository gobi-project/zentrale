FactoryGirl.define do
  factory :device do
    sequence(:name) { |n| "device#{n}" }
    sequence(:address) { |n| "2001:0DB8::#{n}" }
    status :active
  end
end
