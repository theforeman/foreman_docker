require 'test_plugin_helper'

class ImageSearchControllerTest < ActionController::TestCase
  let(:image) { 'centos' }
  let(:tags) { ['latest', '5', '4.3'].map { |tag| "#{term}:#{tag}" } }
  let(:term) { image }

  let(:docker_hub) { Service::RegistryApi.new(url: 'https://nothub.com') }
  let(:compute_resource) { FactoryGirl.create(:docker_cr) }
  let(:registry) { FactoryGirl.create(:docker_registry) }
  let(:image_search_service) { ForemanDocker::ImageSearch.new }

  setup do
    Service::RegistryApi.stubs(:docker_hub).returns(docker_hub)
    ComputeResource::ActiveRecord_Relation.any_instance
      .stubs(:find).returns(compute_resource)
    DockerRegistry::ActiveRecord_Relation.any_instance
      .stubs(:find).returns(registry)
  end

  describe '#auto_complete_repository_name' do
    test 'returns if an image is available' do
      exists = ['true', 'false'].sample
      search_type = ['hub', 'registry'].sample
      subject.instance_variable_set(:@image_search_service, image_search_service)
      image_search_service.expects(:available?).returns(exists)

      xhr :get, :auto_complete_repository_name,
        { registry: search_type, search: term,
          id: compute_resource }, set_session_user
      assert_equal exists, response.body
    end

    context 'it is a Docker Hub tab request' do
      let(:search_type) { 'hub' }

      test 'it queries the compute_resource and Docker Hub' do
        compute_resource.expects(:image).with(term)
          .returns(term)
        compute_resource.expects(:tags_for_local_image)
          .returns(tags)
        docker_hub.expects(:tags).returns([])

        xhr :get, :auto_complete_repository_name,
          { registry: search_type, search: term,
            id: compute_resource }, set_session_user
      end
    end

    context 'it is a External Registry tab request' do
      let(:search_type) { 'registry' }

      test 'it only queries the registry api' do
        compute_resource.expects(:image).with(term).never
        docker_hub.expects(:tags).never
        registry.api.expects(:tags).with(term, nil)
          .returns(['latest'])

        xhr :get, :auto_complete_repository_name,
          { registry: search_type, registry_id: registry,
            search: term, id: compute_resource }, set_session_user
      end
    end
  end

  describe '#auto_complete_image_tag' do
    let(:tag_fragment) { 'lat' }
    let(:term) { "#{image}:#{tag_fragment}"}

    test 'returns an array of { label:, value: } hashes' do
      search_type = ['hub', 'registry'].sample
      subject.instance_variable_set(:@image_search_service, image_search_service)
      image_search_service.expects(:search)
        .with({ term: term, tags: 'true' })
        .returns(tags)
      xhr :get, :auto_complete_image_tag,
        { registry: search_type, search: term,
          id: compute_resource }, set_session_user
      assert_equal tags.first, JSON.parse(response.body).first['value']
    end

    context 'a Docker Hub tab request' do
      let(:search_type) { 'hub' }

      test 'it searches Docker Hub and the ComputeResource' do
        compute_resource.expects(:image).with(image)
          .returns(term)
        compute_resource.expects(:tags_for_local_image)
          .returns(tags)
        docker_hub.expects(:tags).returns([])

        xhr :get, :auto_complete_image_tag,
          { registry: search_type, search: term,
            id: compute_resource }, set_session_user
      end
    end

    context 'it is a External Registry tab request' do
      let(:search_type) { 'registry' }

      test 'it only queries the registry api' do
        compute_resource.expects(:image).with(image).never
        docker_hub.expects(:tags).never
        registry.api.expects(:tags).with(image, tag_fragment)
          .returns([])

        xhr :get, :auto_complete_image_tag,
          { registry: search_type, registry_id: registry,
            search: term, id: compute_resource }, set_session_user
      end
    end
  end

  describe '#search_repository' do
    test 'returns html with the found images' do
      search_type = ['hub', 'registry'].sample
      subject.instance_variable_set(:@image_search_service, image_search_service)
      image_search_service.expects(:search)
        .with({ term: term, tags: 'false' })
        .returns([{ 'name' => term}])
      xhr :get, :search_repository,
        { registry: search_type, search: term,
          id: compute_resource }, set_session_user
      assert response.body.include?(term)
    end

    context 'a Docker Hub tab request' do
      let(:search_type) { 'hub' }

      test 'it searches Docker Hub and the ComputeResource' do
        compute_resource.expects(:local_images)
          .returns([OpenStruct.new(info: { 'RepoTags' => [term] })])
        docker_hub.expects(:search).returns({})

        xhr :get, :search_repository,
          { registry: search_type, search: term,
            id: compute_resource }, set_session_user
      end
    end

    context 'it is a External Registry tab request' do
      let(:search_type) { 'registry' }

      test 'it only queries the registry api' do
        compute_resource.expects(:local_images).with(image).never
        docker_hub.expects(:search).never
        registry.api.expects(:search).with(image)
          .returns({})

        xhr :get, :search_repository,
          { registry: search_type, registry_id: registry,
            search: term, id: compute_resource }, set_session_user
      end
    end
  end

  [Docker::Error::DockerError, Excon::Errors::Error, Errno::ECONNREFUSED].each do |error|
    test 'auto_complete_repository_name catches exceptions on network errors' do
      ForemanDocker::ImageSearch.any_instance.expects(:available?)
        .raises(error)
      xhr :get, :auto_complete_repository_name,
        { registry: 'hub', search: term, id: compute_resource }, set_session_user
      assert_response_is_expected
    end

    test 'auto_complete_image_tag catch exceptions on network errors' do
      ForemanDocker::ImageSearch.any_instance.expects(:search).raises(error)
      xhr :get, :auto_complete_image_tag,
        { registry: 'hub', search:  term, id: compute_resource }, set_session_user
      assert_response_is_expected
    end

    test 'search_repository catch exceptions on network errors' do
      ForemanDocker::ImageSearch.any_instance.expects(:search).raises(error)
      xhr :get, :search_repository,
        { registry: 'hub', search: term, id: compute_resource }, set_session_user
      assert_response_is_expected
    end
  end

  test "centos 7 search responses are handled correctly" do
    repository = "registry-fancycorp.rhcloud.com/fancydb-rhel7/fancydb"
    repo_full_name = "redhat.com: #{repository}"
    request.env["HTTP_ACCEPT"] = "application/javascript"
    expected = [{  "description" => "Really fancy database app...",
                   "is_official" => true,
                   "is_trusted" => true,
                   "name" =>  repo_full_name,
                   "star_count" => 0
                }]
    ForemanDocker::ImageSearch.any_instance.expects(:search).returns(expected).at_least_once
    xhr :get, :search_repository,
      { registry: 'hub', search: 'centos', id: compute_resource }, set_session_user
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
    ForemanDocker::ImageSearch.any_instance.expects(:search).returns(expected).at_least_once
    xhr :get, :search_repository,
      { registry: 'hub', search: 'centos', id: compute_resource  }, set_session_user
    assert_response :success
    assert response.body.include?(repo_full_name)
    assert response.body.include?(repository)
  end

  def assert_response_is_expected
    assert_response :error
    assert response.body.include?('An error occured during repository search:')
  end
end
