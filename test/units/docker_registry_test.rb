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
    registry = as_admin { FactoryGirl.build(:docker_registry) }
    registry.password = 'encrypted-whatever'
    DockerRegistry.any_instance.expects(:encryption_key).at_least_once.returns('fakeencryptionkey')
    assert registry.is_decryptable?(registry.password_in_db)
  end

  %w(name url).each do |property|
    test "registries need a #{property}" do
      refute FactoryGirl.build(:docker_registry, property.to_sym => '').valid?
    end
  end
end
