require 'test_plugin_helper'

class ImageSearchControllerTest < ActionController::TestCase
  setup do
    @container = FactoryGirl.create(:docker_cr)
  end

  [Docker::Error::DockerError, Excon::Errors::Error, Errno::ECONNREFUSED].each do |error|
    test 'auto_complete_repository_name catches exceptions on network errors' do
      ForemanDocker::Docker.any_instance.expects(:exist?).raises(error)
      get :auto_complete_repository_name, { :search => "test", :id => @container.id },
          set_session_user
      assert_response_is_expected
    end

    test 'auto_complete_image_tag catch exceptions on network errors' do
      ForemanDocker::Docker.any_instance.expects(:tags).raises(error)
      get :auto_complete_image_tag, { :search => "test", :id => @container.id }, set_session_user
      assert_response_is_expected
    end

    test 'search_repository catch exceptions on network errors' do
      ForemanDocker::Docker.any_instance.expects(:search).raises(error)
      get :search_repository, { :search => "test", :id => @container.id }, set_session_user
      assert_response_is_expected
    end
  end

  def assert_response_is_expected
    assert_response :error
    assert response.body.include?('An error occured during repository search:')
  end
end
