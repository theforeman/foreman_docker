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

  context 'delete container' do
    setup do
      Fog.mock!
      @container_resource = FactoryGirl.create(:docker_cr)
      @container          = @container_resource.vms.first
    end

    teardown { Fog.unmock! }

    test 'deleting an unmanaged container redirects to containers index' do
      ComputeResource.any_instance.expects(:destroy_vm).with(@container.id)
      delete :destroy, { :compute_resource_id => @container_resource,
                         :id                  => @container.id }, set_session_user
      assert_redirected_to containers_path
      assert_equal "Container #{@container.id} is being deleted.",
        flash[:notice]
    end

    test 'failed deletion of unmanaged container in Docker' do
      ComputeResource.any_instance.stubs(:destroy_vm).
        raises(::Foreman::Exception.new('Could not destroy Docker container'))
      @request.env['HTTP_REFERER'] = "http://test.host/#{containers_path}"
      delete :destroy, { :compute_resource_id => @container_resource,
                         :id                  => @container.id }, set_session_user
      assert @container.present?
      assert_redirected_to :back
      assert_equal 'Your container could not be deleted in Docker',
        flash[:error]
    end

    test 'deleting a managed container deletes container in Docker' do
      managed_container = FactoryGirl.create(
        :container,
        :compute_resource => @container_resource)
      ComputeResource.any_instance.expects(:destroy_vm).
        with('randomuuid')
      Container.any_instance.expects(:uuid).returns('randomuuid').at_least_once
      Container.any_instance.expects(:destroy)
      delete :destroy, { :id => managed_container.id }, set_session_user
      assert_redirected_to containers_path
      assert_equal "Container #{managed_container.uuid} is being deleted.",
        flash[:notice]
    end

    test 'failed deletion of managed container keeps container in Foreman' do
      ComputeResource.any_instance.stubs(:destroy_vm).
        raises(::Foreman::Exception.new('Could not destroy Docker container'))
      managed_container = FactoryGirl.create(
        :container,
        :compute_resource => @container_resource)
      delete :destroy, { :id => managed_container.id }, set_session_user
      assert managed_container.present? # Foreman container would not be deleted
      assert_redirected_to containers_path
      assert_equal 'Your container could not be deleted in Docker',
        flash[:error]
    end
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
