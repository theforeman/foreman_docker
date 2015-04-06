require 'test_plugin_helper'

module Api
  module V2
    class RegistriesControllerTest < ActionController::TestCase
      setup do
        @registry = FactoryGirl.create(:docker_registry)
      end

      test 'index returns a list of all containers' do
        get :index, {}, set_session_user
        assert_response :success
        assert_template 'index'
      end

      test 'index can be filtered by name' do
        %w(thomas clayton wolfe).each do |name|
          FactoryGirl.create(:docker_registry, :name => name)
        end
        get :index, { :search => 'name = thomas' }, set_session_user
        assert_response :success
        assert_equal 1, assigns(:registries).length
      end

      test 'creates a new registry with valid params' do
        docker_attrs = FactoryGirl.attributes_for(:docker_registry)
        post :create, :registry => docker_attrs
        assert_response :success
      end

      test 'does not create a new registry with invalid params' do
        docker_attrs = FactoryGirl.attributes_for(:docker_registry)
        docker_attrs.delete(:name)
        post :create, :registry => docker_attrs
        assert_response 422
      end

      test 'shows a docker registry' do
        get :show, :id => @registry.id
        assert_response :success
      end

      test 'update a docker registry' do
        put :update, :id => @registry.id, :registry => { :name => 'hello_world' }
        assert_response :success
        assert DockerRegistry.exists?(:name => 'hello_world')
      end

      test 'deletes a docker registry' do
        delete :destroy, :id => @registry.id
        assert_response :success
        refute DockerRegistry.exists?(@registry.id)
      end
    end
  end
end
