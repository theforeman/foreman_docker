require 'test_plugin_helper'

class ContainersServiceTest < ActiveSupport::TestCase
  setup do
    @state = DockerContainerWizardState.create! do |s|
      s.build_preliminary(:compute_resource_id => FactoryGirl.create(:docker_cr).id,
                          :locations           => [taxonomies(:location1)],
                          :organizations       => [taxonomies(:organization1)])
      s.build_image(:repository_name => 'test', :tag => 'test')
      s.build_configuration(:name => 'test', :command => '/bin/bash')
      s.build_environment(:tty => false)
    end
  end

  test 'removes current state after successful container creation' do
    ret = OpenStruct.new(:id => 1)
    ForemanDocker::Docker.any_instance.expects(:create_image).returns(ret).with do |subject|
      subject.must_equal(:fromImage => "test:test")
    end
    ForemanDocker::Docker.any_instance.expects(:create_container)
      .returns(OpenStruct.new(:uuid => 1))
    Fog.mock!
    Service::Containers.new.start_container!(@state)
    Fog.unmock!
    assert_equal DockerContainerWizardState.where(:id => @state.id).count, 0
  end
end
