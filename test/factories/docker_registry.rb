FactoryBot.define do
  factory :docker_registry do
    sequence(:name) { |n| "hub#{n}" }
    sequence(:url) { |n| "http://localhost/#{n}" }
    sequence(:username) { |n| "username#{n}" }
    sequence(:password) { |n| "password#{n}" }
  end

  after(:build) do |registry|
    registry.stubs(:attempt_login)
  end

  trait :with_location do
    locations { [FactoryBot.build(:location)] }
  end

  trait :with_organization do
    organizations { [FactoryBot.build(:organization)] }
  end
end
