require 'test_plugin_helper'

module Api
  module V2
    class RegistriesControllerTest < ActionController::TestCase
      setup do
        @registry = FactoryBot.create(:docker_registry)
      end

      test 'index returns a list of all containers' do
        get :index, session: set_session_user
        assert_response :success
        assert_template 'index'
      end

      test 'index can be filtered by name' do
        %w(thomas clayton wolfe).each do |name|
          FactoryBot.create(:docker_registry, :name => name)
        end
        get :index, params: { :search => 'name = thomas' }, session: set_session_user
        assert_response :success
        assert_equal 1, assigns(:registries).length
      end

      test 'creates a new registry with valid params' do
        docker_attrs = FactoryBot.attributes_for(:docker_registry)
        DockerRegistry.any_instance.stubs(:attempt_login)
        post :create, params: { :registry => docker_attrs }
        assert_response :success
      end

      test 'does not create a new registry with invalid params' do
        docker_attrs = FactoryBot.attributes_for(:docker_registry)
        docker_attrs.delete(:name)
        post :create, params: { :registry => docker_attrs }
        assert_response 422
      end

      test 'shows a docker registry' do
        get :show, params: { :id => @registry.id }
        assert_response :success
      end

      test 'update a docker registry' do
        DockerRegistry.any_instance.stubs(:attempt_login)
        new_name = 'hello_world'
        put :update, params: { :id => @registry.id, :registry => { :name => new_name } }
        assert_response :success
        assert_equal new_name, @registry.reload.name
      end

      test 'deletes a docker registry' do
        delete :destroy, params: { :id => @registry.id }
        assert_response :success
        assert DockerRegistry.where(:id => @registry.id).blank?
      end
    end
  end
end
