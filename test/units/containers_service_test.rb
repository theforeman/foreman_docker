require 'test_plugin_helper'
require 'ostruct'

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

  context 'errors' do
    setup do
      @containers_service = Service::Containers.new
    end

    test 'from compute resource' do
      # Since the compute resource will be unreachable, this test will always
      # fail at the 'pull_image' step
      assert_raises(ActiveRecord::Rollback) do
        @containers_service.create_container_object(@state)
      end
      assert @containers_service.errors.present?
      assert_match(/No such file or directory.*ENOENT/,
                   @containers_service.full_messages.join(' '))
    end

    test 'from multiple sources' do
      Container.any_instance.expects(:valid?).returns(false)
      Container.any_instance.stubs(:errors).returns(
        OpenStruct.new(:full_messages => ['foo']))
      assert_raises(ActiveRecord::Rollback) do
        @containers_service.create_container_object(@state)
      end
      assert @containers_service.errors.present?
      assert_match(/foo/,
                   @containers_service.full_messages.join(' '))
    end
  end
end
