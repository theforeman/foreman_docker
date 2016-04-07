require 'test_plugin_helper'

module ForemanDocker
  class ContainerRemoverTest < ActiveSupport::TestCase
    describe '#remove_unmanaged' do
      setup do
        @docker_compute_resource = FactoryGirl.build_stubbed(:docker_cr)
        ComputeResource.expects(:authorized).
          with(:destroy_compute_resources_vms).
          returns(stub(:find => @docker_compute_resource))

        Fog.mock!
      end

      teardown { Fog.unmock! }

      test 'remove_unmanaged makes call to the Docker API' do
        @docker_compute_resource.expects(:destroy_vm).with('random-uuid')

        assert ForemanDocker::ContainerRemover.remove_unmanaged(
          @docker_compute_resource.id, 'random-uuid')
      end

      test 'remove_unmanaged returns deleted_identifier' do
        assert_equal 'random-uuid',
          ForemanDocker::ContainerRemover.remove_unmanaged(
            @docker_compute_resource.id, 'random-uuid')
      end
    end
  end
end
