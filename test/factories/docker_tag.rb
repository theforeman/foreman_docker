FactoryGirl.define do
  factory :docker_tag do
    sequence(:tag) { |n| "tag#{n}" }
    association :image, :factory => :docker_image
  end
end
