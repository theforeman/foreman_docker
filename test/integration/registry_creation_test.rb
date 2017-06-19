require 'integration_test_helper'

class RegistryiCreationTest < IntegrationTestWithJavascript
  let(:registry_values) { FactoryGirl.build(:docker_registry) }

  setup do
    DockerRegistry.any_instance.stubs(:attempt_login).returns(true)
    visit new_registry_path
  end

  test 'can create a registy' do
    assert_difference('DockerRegistry.count') do
      fill_in 'docker_registry_name', with: registry_values.name
      fill_in 'docker_registry_url', with: registry_values.url
      page.find('#new_docker_registry .btn-primary').click
      wait_for_ajax
    end
  end
end
