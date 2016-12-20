require 'test_plugin_helper'

module ForemanDocker
  class ComputeResourceExtensionsTest < ActiveSupport::TestCase
    test 'ComputeResource::providers_requiring_url returns expected providers' do
      expected_providers = "Docker, Libvirt, oVirt, OpenStack and Rackspace"
      assert_equal expected_providers, ComputeResource.providers_requiring_url
    end
  end
end
