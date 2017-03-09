require 'test_plugin_helper'

class RegistryApiTest < ActiveSupport::TestCase
  let(:url) { 'http://dockerregistry.com:5000' }
  subject { Service::RegistryApi.new(url: url) }

  describe '#connection' do
    test 'returns a Docker::Connection' do
      assert_equal Docker::Connection, subject.connection.class
    end

    test 'the connection has the same url' do
      assert_equal url, subject.connection.url
    end

    context 'authentication is set' do
      let(:user) { 'username' }
      let(:password) { 'secretpassword' }

      subject do
        Service::RegistryApi.new({
          url: url,
          password: password,
          user: user })
      end

      test 'it sets the same user and password' do
        assert_equal user, subject.connection.options[:user]
        assert_equal password, subject.connection.options[:password]
      end
    end
  end

  describe '#get' do
    let(:path) { '/v1/search' }
    let(:json) { '{}' }

    test 'calls get on #connection' do
      subject.connection
        .expects(:get).at_least_once
        .returns(json)

      subject.get(path)
    end

    test 'returns a parsed json' do
      subject.connection.stubs(:get).returns(json)
      assert_equal JSON.parse(json), subject.get(path)
    end

    # Docker::Connection is used and meant for the Docker,
    # not the Registry API therefore it is required
    # to override the path via options
    test 'sets the path as an option not param for Docker::Connection#get' do
      subject.connection.stubs(:get) do |path_param, _, options|
        refute_equal path, path_param
        assert_equal path, options[:path]
      end.returns(json)

      subject.get(path)
    end

    # Docker Hub will return a 503 when a 'Host' header includes a port.
    # Omitting default ports (an Excon option) solves the issue
    test 'sets omit_default_port to true' do
      subject.connection.stubs(:get) do |_, _, options|
        assert options[:omit_default_port]
      end.returns(json)

      subject.get(path)
    end

    test 'returns the response raw body if it is not JSON' do
      response = 'This is not JSON'
      subject.connection.stubs(:get)
        .returns(response)
      assert_equal response, subject.get('/v1/')
    end
  end

  describe '#search' do
    let(:path) { '/v1/search' }
    let(:query) { 'centos' }

    test "calls #get with path and query" do
      subject.expects(:get).with(path, {q: query}) do |path_param, params|
        assert_equal path, path_param
        assert_equal query, params[:q]
      end.returns({})

      subject.search(query)
    end

    test "falls back to #catalog if #get fails" do
      subject.expects(:catalog).with(query)

      subject.expects(:get).with(path, {q: query})
        .raises('Error')

      subject.search(query)
    end
  end

  describe '#catalog' do
    let(:path) { '/v2/_catalog' }
    let(:query) { 'centos' }
    let(:catalog) { { 'repositories' => ['centos', 'fedora'] } }

    setup do
      subject.stubs(:get).returns(catalog)
    end

    test "calls #get with path" do
      subject.expects(:get).with(path)
        .returns(catalog)

      subject.catalog(query)
    end

    test 'returns {"name" => value} pairs' do
      result = subject.catalog(query)
      assert_equal({ "name" => query }, result.first)
    end

    test 'only give back matching results' do
      result = subject.catalog('fedora')
      assert_match(/^fedora/, result.first['name'])
    end
  end

  describe '#tags' do
    let(:query) { 'alpine' }
    let(:path) { "/v1/repositories/#{query}/tags" }

    test "calls #get with path" do
      subject.expects(:get).with(path)
      subject.tags(query)
    end

    test "falls back to #tags_v2 if #get fails" do
      subject.expects(:get).with(path)
        .raises('Error')

      subject.expects(:tags_v2).with(query)
      subject.tags(query)
    end

    # https://registry.access.redhat.com returns a hash not an array
    test 'handles a hash response correctly' do
      tags_hash = {
        "7.0-21": "e1f5733f050b2488a17b7630cb038bfbea8b7bdfa9bdfb99e63a33117e28d02f",
	"7.0-23": "bef54b8f8a2fdd221734f1da404d4c0a7d07ee9169b1443a338ab54236c8c91a",
	"7.0-27": "8e6704f39a3d4a0c82ec7262ad683a9d1d9a281e3c1ebbb64c045b9af39b3940"
      }
      subject.expects(:get).with(path)
        .returns(tags_hash)
      assert_equal '7.0-21', subject.tags(query).first['name']
    end
  end

  describe '#tags for API v2' do
    let(:query) { 'debian' }
    let(:v1_path) { "/v1/repositories/#{query}/tags" }
    let(:path) { "/v2/#{query}/tags/list" }
    let(:tags) { { 'tags' => ['jessy', 'woody'] } }

    setup do
      subject.stubs(:get).with(v1_path)
        .raises('404 Not found')
    end

    test 'calls #get with path' do
      subject.expects(:get).with(path)
        .returns(tags)
      subject.tags(query)
    end

    test 'returns {"name" => value } pairs ' do
      subject.stubs(:get).with(path).returns(tags)
      result = subject.tags(query)
      assert_equal tags['tags'].first, result.first['name']
    end
  end

  describe '#ok?' do
    test 'calls the API via #get with /v1/' do
      subject.connection.expects(:get)
        .with('/', nil, Service::RegistryApi::DEFAULTS[:connection].merge({ path: '/v1/' }))
        .returns('Docker Registry API')
      assert subject.ok?
    end

    test 'calls #get with /v2/ if /v1/fails' do
      subject.stubs(:get).with('/v1/')
        .raises('404 page not found')
      subject.expects(:get).with('/v2/')
        .returns({})
      assert subject.ok?
    end
  end

  describe '.docker_hub' do
    subject { Service::RegistryApi }

    test 'returns an instance for Docker Hub' do
      result = subject.docker_hub
      assert_equal Service::RegistryApi::DOCKER_HUB, result.url
    end
  end
end
