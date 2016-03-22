require 'integration_test_helper'

class ContainerIntegrationTest < ActionDispatch::IntegrationTest
  test 'redirects to a new compute resource if none is available' do
    visit containers_path
    assert_equal current_path, new_compute_resource_path
  end

  context 'available compute resource' do
    test 'shows containers list if compute resource is available' do
      Fog.mock!
      ComputeResource.any_instance.stubs(:vms).returns([])
      FactoryGirl.create(:docker_cr)
      visit containers_path
      assert page.has_link? 'New container'
      refute_equal current_path, new_compute_resource_path
    end
  end
end
