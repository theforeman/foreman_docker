FactoryGirl.define do
  factory :docker_tag do
    sequence(:tag) { |n| "tag#{n}" }
    docker_image
  end
end
