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
          @registry = FactoryGirl.create(:docker_registry)
          @compute_resource = FactoryGirl.create(:docker_cr)
        end

        test 'logs returns latest lines of container log' do
          fake_container = Struct.new(:logs)
          fake_container.expects(:logs).returns('I am a log').twice
          Docker::Container.expects(:get).with(@container.uuid).returns(fake_container)
          get :logs, :id => @container.id
          assert_response :success
          assert_equal ActiveSupport::JSON.decode(response.body)['logs'], fake_container.logs
        end

        test 'show returns information about container' do
          get :show, :id => @container.id
          assert_response :success
          assert_equal ActiveSupport::JSON.decode(response.body)['name'], 'foo'
        end

        context 'deletion' do
          setup do
            Container.any_instance.stubs(:uuid).returns('randomuuid')
          end

          test 'delete removes a container in foreman and in Docker host' do
            delete :destroy, :id => @container.id
            assert_response :success
            assert_equal ActiveSupport::JSON.decode(response.body)['name'], 'foo'
          end

          test 'if deletion on Docker host fails, Foreman deletion fails' do
            ComputeResource.any_instance.expects(:destroy_vm).
              with('randomuuid').
              raises(::Foreman::Exception.new('Problem removing container'))
            delete :destroy, :id => @container.id
            assert_response :precondition_failed
          end
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
          repository_name = "centos"
          tag = "7"
          name = "foo"
          registry_uri = URI.parse(@registry.url)
          Service::Containers.any_instance.expects(:pull_image).returns(true)
          Service::Containers.any_instance
            .expects(:start_container).returns(true).with do |container|
            container.must_be_kind_of(Container)
            container.repository_name.must_equal(repository_name)
            container.tag.must_equal(tag)
            container.compute_resource_id.must_equal(@compute_resource.id)
            container.name.must_equal(name)
            container.repository_pull_url.must_include(registry_uri.host)
            container.repository_pull_url.must_include("#{repository_name}:#{tag}")
          end
          post :create, :container => { :compute_resource_id => @compute_resource.id,
                                        :name => name,
                                        :registry_id => @registry.id,
                                        :repository_name => repository_name,
                                        :tag => tag }
          assert_response :created
        end

        test 'creates a katello container with correct params' do
          DockerContainerWizardStates::Image.class_eval do
            attr_accessor :capsule_id
          end
          DockerContainerWizardStates::Image.attribute_names.stubs(:include?).returns(true)
          repository_name = "katello_centos"
          tag = "7"
          name = "foo"
          capsule_id = "10000"
          Service::Containers.any_instance.expects(:start_container!)
            .returns(@container).with do |wizard_state|
            wizard_state.must_be_kind_of(DockerContainerWizardState)
            container_attributes = wizard_state.container_attributes
            container_attributes[:repository_name].must_equal(repository_name)
            container_attributes[:tag].must_equal(tag)
            container_attributes[:compute_resource_id].must_equal(@compute_resource.id)
            container_attributes[:name].must_equal(name)
            wizard_state.image.capsule_id.must_equal(capsule_id)
          end
          post :create, :container => { :compute_resource_id => @compute_resource.id,
                                        :name => name,
                                        :capsule_id => capsule_id,
                                        :repository_name => repository_name,
                                        :tag => tag }
          assert_response :created
        end

        test 'creation fails with invalid container name' do
          post :create, :container => { :compute_resource_id => @container.compute_resource_id,
                                        :name => @container.name,
                                        :registry_id => @registry.id,
                                        :repository_name => 'centos',
                                        :tag => 'latest' }
          assert_response :unprocessable_entity
        end
      end
    end
  end
end
