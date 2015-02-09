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

  test 'password is stored encrypted' do
    registry = as_admin { FactoryGirl.create(:docker_registry) }
    assert registry.is_decryptable?(registry.password_in_db)
  end

  test 'registries need a name' do
    registry = FactoryGirl.build(:docker_registry, :name => '')
    refute registry.valid?
  end
end
