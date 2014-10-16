FactoryGirl.define do
  factory :docker_image do
    sequence(:image_id) { |n| "image#{n}" }
  end
end
