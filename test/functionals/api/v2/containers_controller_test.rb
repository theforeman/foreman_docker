require 'test_plugin_helper'

module Api
  module V2
    class ContainersControllerTest < ActionController::TestCase
      test 'index returns a list of all containers' do
        get :index, {}, set_session_user
        assert_response :success
        assert_template 'index'
      end

      test 'index can be filtered by name' do
        %w(thomas clayton wolfe).each do |name|
          FactoryGirl.create(:container, :name => name)
        end
        get :index, { :search => 'name = thomas' }, set_session_user
        assert_response :success
        assert_equal 1, assigns(:containers).length
      end

      context 'container operations' do
        setup do
          @container = FactoryGirl.create(:container, :name => 'foo')
        end

        test 'logs returns latest lines of container log' do
          fake_container = Struct.new(:logs)
          fake_container.expects(:logs).returns('I am a log').twice
          Docker::Container.expects(:get).with(@container.uuid).returns(fake_container)
          get :logs, :id => @container.id
          assert_response :success
          assert_equal ActiveSupport::JSON.decode(response.body)['logs'], fake_container.logs
        end

        test 'show returns information about container'  do
          get :show, :id => @container.id
          assert_response :success
          assert_equal ActiveSupport::JSON.decode(response.body)['name'], 'foo'
        end

        test 'delete removes a container in foreman and in Docker host' do
          delete :destroy, :id => @container.id
          assert_response :success
          assert_equal ActiveSupport::JSON.decode(response.body)['name'], 'foo'
        end

        test 'power call turns on/off container in Docker host' do
          Fog.mock!
          Fog::Compute::Fogdocker::Server.any_instance.expects(:start)
          put :power, :id => @container.id, :power_action => 'start'
          assert_response :success
        end

        test 'power call checks status of container in Docker host' do
          Fog.mock!
          Fog::Compute::Fogdocker::Server.any_instance.expects(:ready?).returns(false)
          put :power, :id => @container.id, :power_action => 'status'
          assert_response :success
          assert_equal ActiveSupport::JSON.decode(response.body)['running'], false
        end

        test 'power call host' do
          Fog.mock!
          Fog::Compute::Fogdocker::Server.any_instance.expects(:ready?).returns(false)
          put :power, :id => @container.id, :power_action => 'status'
          assert_response :success
          assert_equal ActiveSupport::JSON.decode(response.body)['running'], false
        end

        test 'creates a container with correct params' do
          Service::Containers.any_instance.expects(:pull_image).returns(true)
          Service::Containers.any_instance.expects(:start_container).returns(true)
          post :create, :container => { :name => 'foo', :registry_id => 3, :image => 'centos:7' }
          assert_response :created
        end
      end
    end
  end
end
