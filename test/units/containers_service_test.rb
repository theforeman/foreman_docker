require 'test_plugin_helper'

class ContainersServiceTest <  ActiveSupport::TestCase
  setup do
    @state = DockerContainerWizardState.create! do |s|
      s.build_preliminary(:compute_resource_id => FactoryGirl.create(:docker_cr).id)
      s.build_image(:repository_name => 'test', :tag => 'test')
      s.build_configuration(:name => 'test')
      s.build_environment(:tty => false)
    end
  end

  test 'removes current state after successful container creation' do
    ForemanDocker::Docker.any_instance
      .expects(:create_container)
      .returns(OpenStruct.new(:uuid => 1))
    Service::Containers.start_container!(@state)
    assert DockerContainerWizardState.where(:id => @state.id).count == 0
  end
end
