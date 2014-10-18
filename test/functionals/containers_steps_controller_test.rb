require 'test_plugin_helper'

module Containers
  class StepsControllerTest < ActionController::TestCase
    test 'setting a docker image and tag for a new container' do
      @container = FactoryGirl.create(:container)
      put :update, { :id => :image,
                     :container_id => @container,
                     :image => 'centos',
                     :container => { :tag => 'latest' } }, set_session_user
      assert_response :found
      assert_redirected_to container_step_path(:container_id => @container.id,
                                               :id           => :configuration)
      assert_equal DockerImage.find_by_image_id('centos'), @container.reload.image
      assert_equal DockerTag.find_by_tag('latest'), @container.tag
    end
  end
end
