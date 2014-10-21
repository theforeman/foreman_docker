require 'test_plugin_helper'

module Containers
  class StepsControllerTest < ActionController::TestCase
    setup do
      @container = FactoryGirl.create(:container)
    end

    test 'sets a docker image and tag for a new container' do
      put :update, { :id => :image,
                     :container_id => @container.id,
                     :image => 'centos',
                     :container => { :tag => 'latest' } }, set_session_user
      assert_response :found
      assert_redirected_to container_step_path(:container_id => @container.id,
                                               :id           => :configuration)
      assert_equal DockerImage.find_by_image_id('centos'), @container.reload.image
      assert_equal DockerTag.find_by_tag('latest'), @container.tag
    end

    test 'uuid of the created container is saved at the end of the wizard' do
      Fog.mock!
      @container.update_attribute(:image, 'centos')
      @container.update_attribute(:tag,   'latest')
      fake_container    = @container.compute_resource.create_vm
      fake_container.id = SecureRandom.uuid
      ForemanDocker::Docker.any_instance.expects(:create_vm).returns(fake_container)
      put :update, { :id => :environment,
                     :container_id => @container.id }, set_session_user
      assert_equal fake_container.id, Container.find(@container.id).uuid
    end

    test 'wizard finishes with a redirect to the managed container' do
      get :show, { :id => :wicked_finish,
                   :container_id => @container.id }, set_session_user
      assert_redirected_to container_path(:id => @container.id)
    end
  end
end
