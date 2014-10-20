FactoryGirl.define do
  factory :container do
    sequence(:name) { |n| "container_#{n}" }
    association :compute_resource, :factory => :docker_cr
  end
end
