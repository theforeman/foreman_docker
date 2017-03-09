require 'test_plugin_helper'

class ImageSearchServiceTest < ActiveSupport::TestCase
  let(:compute_resource) { FactoryGirl.create(:docker_cr) }
  let(:registry) { FactoryGirl.create(:docker_registry).api }
  let(:term) { 'centos' }
  let(:query) { { term: term, tags: 'false' } }

  subject { ForemanDocker::ImageSearch.new(compute_resource, registry) }

  setup do
    stub_registry_api
  end

  describe '#add_source' do
    setup do
      subject.instance_variable_set(:@sources, {})
    end

    test 'adds a compute resource to @sources[:compute_resource]' do
      subject.add_source(compute_resource)
      assert_equal compute_resource,
                   subject.instance_variable_get(:@sources)[:compute_resource].first
    end

    test 'adds a registry to @sources[:registry]' do
      subject.add_source(registry)
      assert_equal registry,
                   subject.instance_variable_get(:@sources)[:registry].first
    end
  end

  describe '#remove_source' do
    test 'removes a registry source from @sources' do
      refute subject.instance_variable_get(:@sources)[:registry].empty?
      subject.remove_source(registry)
      assert subject.instance_variable_get(:@sources)[:registry].empty?
    end

    test 'removes a compute_resource source from @sources' do
      refute subject.instance_variable_get(:@sources)[:compute_resource].empty?
      subject.remove_source(compute_resource)
      assert subject.instance_variable_get(:@sources)[:compute_resource].empty?
    end
  end

  describe '#search' do
    test 'returns {"name" => value } pairs' do
      return_result = Hash.new
      return_result.stubs(:info).returns({ 'RepoTags' => ["#{term}:latest"]})
      compute_resource.stubs(:local_images).with(term)
        .returns([return_result])
      result = subject.search(query)
      assert_equal({"name" => term}, result.first)
    end

    context 'tags is false' do
      test 'calls #images with term as query' do
        subject.expects(:images).with(term)
          .returns([])
        subject.search(query)
      end
    end

    context 'tags is "true"' do
      setup do
        query[:tags] = 'true'
      end

      test 'calls #tags with term as query' do
        subject.expects(:tags).with(term)
          .returns([])
        subject.search(query)
      end
    end
  end

  describe '#images' do
    context 'a compute_resource set' do
      test 'calls #search_compute_resource with term as query' do
        subject.expects(:compute_resource_search).with(compute_resource, term)
          .returns([])
        subject.images(term)
      end
    end

    context 'no compute_resource is set' do
      setup do
        subject.remove_source(compute_resource)
      end

      test 'does not call #search_compute_resource' do
        subject.expects(:compute_resource_search).with(compute_resource, term)
          .never
        subject.images(term)
      end
    end

    context 'a registry is set' do
      test 'calls #search_registry' do
        subject.expects(:registry_search).with(registry, term)
          .returns([])
        subject.images(term)
      end
    end

    context 'no registry is set' do
      setup do
        subject.remove_source(registry)
      end

      test 'does not call #search_registry' do
        subject.expects(:registry_search).with(registry, term)
          .never
        subject.images(term)
      end
    end
  end

  describe '#tags' do
    let(:tag) { 'latest' }
    let(:query) { "#{term}:#{tag}" }

    context 'a compute_resource set' do
      test 'calls #compute_resource with image name and tag' do
        subject.expects(:compute_resource_tags).with(compute_resource, term, tag)
          .returns([])
        subject.tags(query)
      end
    end

    context 'no compute_resource is set' do
      setup do
        subject.remove_source(compute_resource)
      end

      test 'does not call #search_compute_resource' do
        subject.expects(:compute_resource_tags).with(compute_resource, term, tag)
          .never
        subject.tags(query)
      end
    end

    context 'a registry is set' do
      setup do
        subject.remove_source(compute_resource)
      end

      test 'calls #registry_tags with image name and tag' do
        subject.expects(:registry_tags).with(registry, term, tag)
          .returns([])
        subject.tags(query)
      end
    end

    context 'no registry is set' do
      setup do
        subject.remove_source(registry)
      end

      test 'does not call #registry_tags' do
        subject.expects(:registry_search).with(registry, term, tag)
          .never
        subject.images(query)
      end
    end
  end

  describe '#available?' do
    test 'calls #tags with query' do
      subject.expects(:tags).with(query).once
        .returns([])
      subject.available?(query)
    end

    test 'returns true if any matching image and tag is found' do
      subject.stubs(:tags).with(query)
        .returns([{ 'name' => "#{term}:latest" }])
      subject.available?(query)
    end

    test 'returns false if none are found' do
      subject.stubs(:tags).with(query)
        .returns([])
      subject.available?(query)
    end
  end
end
