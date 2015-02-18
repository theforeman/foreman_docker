require 'test_plugin_helper'

class ContainersControllerTest < ActionController::TestCase
  test 'redirect if Docker provider is not available' do
    get :index, {}, set_session_user
    assert_redirected_to new_compute_resource_path
  end

  test 'index if Docker resource is available' do
    Fog.mock!
    # Avoid rendering errors by not retrieving any container
    ComputeResource.any_instance.stubs(:vms).returns([])
    FactoryGirl.create(:docker_cr)
    get :index, {}, set_session_user
    assert_template 'index'
  end

  test 'deleting a container in compute resource redirects to containers index' do
    Fog.mock!
    container_resource = FactoryGirl.create(:docker_cr)
    container          = container_resource.vms.first
    container.class.any_instance.expects(:destroy).returns(true)
    delete :destroy, { :compute_resource_id => container_resource,
                       :id                  => container.id }, set_session_user
    assert_redirected_to containers_path
  end

  test 'committing a managed container' do
    container = FactoryGirl.create(:container)
    request.env['HTTP_REFERER'] = container_path(:id => container.id)
    commit_hash = { :author => 'a', :repo => 'b', :tag => 'c', :comment => 'd' }

    mock_container = mock
    ::Docker::Container.expects(:get).with(container.uuid, anything, anything)
      .returns(mock_container)
    mock_container.expects(:commit).with(commit_hash)

    post :commit, { :commit => commit_hash,
                    :id     => container.id }, set_session_user
  end
end
