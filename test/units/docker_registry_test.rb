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

  should validate_presence_of(:name)
  should validate_presence_of(:url)
  should validate_uniqueness_of(:name)
  should validate_uniqueness_of(:url)

  context 'attempt to login' do
    setup do
      @registry = FactoryGirl.build(:docker_registry)
      @registry.unstub(:attempt_login)
    end

    test 'before creating a registry' do
      RestClient::Resource.any_instance.expects(:get)
      assert @registry.valid?
    end

    test 'display errors in case authentication failed' do
      RestClient::Resource.any_instance.expects(:get).
        raises(Docker::Error::AuthenticationError)
      refute @registry.valid?
    end
  end
end
