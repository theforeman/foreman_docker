FactoryGirl.define do
  factory :container do
    sequence(:name) { |n| "container_#{n}" }
  end
end
