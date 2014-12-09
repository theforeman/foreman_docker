FactoryGirl.define do
  factory :container do
    sequence(:name) { |n| "container_#{n}" }
    association :compute_resource, :factory => :docker_cr
    sequence(:repository_name) { |n| "repo#{n}" }
    sequence(:tag) { |n| "tag#{n}" }
  end
end
