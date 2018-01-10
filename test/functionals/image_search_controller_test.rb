require 'test_plugin_helper'

class ImageSearchControllerTest < ActionController::TestCase
  let(:docker_image) { 'centos' }
  let(:tags) { ['latest', '5', '4.3'].map { |tag| "#{term}:#{tag}" } }
  let(:term) { docker_image }

  let(:docker_hub) { Service::RegistryApi.new(url: 'https://nothub.com') }
  let(:compute_resource) { FactoryBot.create(:docker_cr) }
  let(:registry) { FactoryBot.create(:docker_registry) }
  let(:image_search_service) { ForemanDocker::ImageSearch.new }

  setup do
    Service::RegistryApi.stubs(:docker_hub).returns(docker_hub)
    ComputeResource.const_get(:ActiveRecord_Relation).any_instance
      .stubs(:find).returns(compute_resource)
    DockerRegistry.const_get(:ActiveRecord_Relation).any_instance
      .stubs(:find).returns(registry)
  end

  # rubocop:disable Metrics/BlockLength
  describe '#search_repository' do
    let(:search_types) { ['hub', 'registry'] }

    describe 'calls #search on image_search_service' do
      setup do
        subject.instance_variable_set(:@image_search_service, image_search_service)
      end

      test 'passes params search and tags' do
        tags_enabled = ['true', 'false'].sample
        image_search_service.expects(:search).with({ term: term, tags: tags_enabled })
          .returns([])
        get :search_repository,
            params: { registry: search_types.sample, search: term, tags: tags_enabled,
                      id: compute_resource },
            session: set_session_user,
            xhr: true
      end

      test 'returns an array of { label:, value: } hashes' do
        image_search_service.expects(:search).with({ term: term, tags: 'true' })
          .returns(tags)
        get :search_repository,
            params: { registry: search_types.sample, search: term, tags: 'true',
                      id: compute_resource },
            session: set_session_user,
            xhr: true

        assert_equal tags.first, JSON.parse(response.body).first['value']
      end

      test 'returns html with the found images' do
        image_search_service.expects(:search)
          .with({ term: term, tags: 'false' })
          .returns([{ 'name' => term }])
        get :search_repository, params:
          { registry: search_types.sample, search: term,
            id: compute_resource, format: :html },
            session: set_session_user, xhr: true

        assert response.body.include?(term)
      end

      [Docker::Error::DockerError, Excon::Errors::Error, Errno::ECONNREFUSED].each do |error|
        test "search_repository catch exceptions on network errors like #{error}" do
          image_search_service.expects(:search)
            .raises(error)
          get :search_repository,
              params: { registry: search_types.sample, search: term, id: compute_resource },
              session: set_session_user, xhr: true

          assert_response :error
          assert response.body.include?('An error occured during repository search:')
        end
      end

      test "centos 7 search responses are handled correctly" do
        repository = "registry-fancycorp.rhcloud.com/fancydb-rhel7/fancydb"
        repo_full_name = "redhat.com: #{repository}"
        expected = [{  "description" => "Really fancy database app...",
                       "is_official" => true,
                       "is_trusted" => true,
                       "name" =>  repo_full_name,
                       "star_count" => 0
                    }]
        image_search_service.expects(:search).returns(expected)
        get :search_repository,
            params: { registry: search_types.sample, search: 'centos', id: compute_resource, format: :html },
            session: set_session_user,
            xhr: true

        assert_response :success
        refute response.body.include?(repo_full_name)
        assert response.body.include?(repository)
      end

      test "fedora search responses are handled correctly" do
        repository = "registry-fancycorp.rhcloud.com/fancydb-rhel7/fancydb"
        repo_full_name = repository
        request.env["HTTP_ACCEPT"] = "application/javascript"
        expected = [{ "description" => "Really fancy database app...",
                      "is_official" => true,
                      "is_trusted" => true,
                      "name" =>  repo_full_name,
                      "star_count" => 0
                    }]
        image_search_service.expects(:search).returns(expected)
        get :search_repository,
            params: { registry: search_types.sample, search: term, id: compute_resource, format: :html },
            session: set_session_user,
            xhr: true

        assert_response :success
        assert response.body.include?(repo_full_name)
        assert response.body.include?(repository)
      end
    end

    describe 'for image names' do
      context 'with a Docker Hub tab request' do
        let(:search_type) { 'hub' }

        test 'it searches Docker Hub and the ComputeResource' do
          compute_resource.expects(:local_images)
            .returns([OpenStruct.new(info: { 'RepoTags' => [term] })])
          docker_hub.expects(:search).returns({})

          get :search_repository,
              params:  { registry: search_type, search: term,
                         id: compute_resource },
              session: set_session_user,
              xhr: true
        end
      end

      context 'with a External Registry tab request' do
        let(:search_type) { 'registry' }

        test 'it only queries the registry api' do
          compute_resource.expects(:local_images).with(docker_image).never
          docker_hub.expects(:search).never
          registry.api.expects(:search).with(docker_image)
            .returns({})

          get :search_repository,
              params: { registry: search_type, registry_id: registry,
              search: term, id: compute_resource },
              session: set_session_user,
              xhr: true
        end
      end
    end

    describe 'for tags' do
      let(:tag_fragment) { 'lat' }
      let(:term) { "#{docker_image}:#{tag_fragment}"}

      context 'with a Docker Hub tab request' do
        let(:search_type) { 'hub' }

        test 'it searches Docker Hub and the ComputeResource' do
          compute_resource.expects(:image).with(docker_image)
            .returns(term)
          compute_resource.expects(:tags_for_local_image)
            .returns(tags)
          docker_hub.expects(:tags).returns([])

          get :search_repository,
              params: { registry: search_type, search: term,
                        tags: 'true', id: compute_resource },
              session: set_session_user,
              xhr: true
        end
      end

      context 'with a External Registry tab request' do
        let(:search_type) { 'registry' }

        test 'it only queries the registry api' do
          compute_resource.expects(:image).with(docker_image).never
          docker_hub.expects(:tags).never
          registry.api.expects(:tags).with(docker_image, tag_fragment)
            .returns([])

          get :search_repository,
              params: { registry: search_type, registry_id: registry, tags: 'true',
                        search: term, id: compute_resource },
              session: set_session_user,
              xhr: true
        end
      end
    end
  end
end
