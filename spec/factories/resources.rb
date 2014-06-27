FactoryGirl.define do
  factory :resource do
    sequence(:name) { |n| "resource#{n}" }
    sequence(:path) { |n| "/path/#{n}" }
    sequence(:device_id) { |n| n }
    unit '°C'
    interface_type 'core.s'
    resource_type 'gobi.s.tmp'
  end
end
