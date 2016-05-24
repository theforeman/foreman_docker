FactoryGirl.define do
  factory :container_resource, :class => ComputeResource do
    sequence(:name) { |n| "compute_resource#{n}" }

    trait :docker do
      provider 'Docker'
      user 'dockeruser'
      password 'dockerpassword'
      email 'container@containerization.com'
      url 'unix:///var/run/docker.falsesock'
    end

    factory :docker_cr, :class => ForemanDocker::Docker, :traits => [:docker]
  end
end
