require 'test_plugin_helper'

module Containers
  class StepsControllerTest < ActionController::TestCase
    test 'setting a docker image and tag for a new container' do
      @container = FactoryGirl.create(:container)
      put :update, :id => :image,
                   :container_id => @container,
                   :image => "centos",
                   :container => { :tag => "latest" }
      assert_response 302
      assert_equal "latest", @container.reload.tag
      assert_equal "centos", @container.image
    end
  end
end
