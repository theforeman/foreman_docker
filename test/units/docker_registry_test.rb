require 'test_plugin_helper'

class DockerRegistryTest < ActiveSupport::TestCase
  test 'used_location_ids should return correct location ids' do
    location = FactoryGirl.build(:location)
    r = as_admin do
      FactoryGirl.create(:docker_registry, :locations => ([location]))
    end
    assert r.used_location_ids.include?(location.id)
  end

  test 'used_organization_ids should return correct organization ids' do
    organization = FactoryGirl.build(:organization)
    r = as_admin do
      FactoryGirl.create(:docker_registry, :organizations => ([organization]))
    end
    assert r.used_organization_ids.include?(organization.id)
  end
end
