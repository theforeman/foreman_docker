require 'test_plugin_helper'

module DockerContainerWizardStates
  class ImageTest < ActiveSupport::TestCase
    let(:image) { 'centos' }
    let(:tags) { ['latest', '5', '4.3'] }
    let(:docker_hub) { Service::RegistryApi.new(url: 'https://nothub.com') }
    let(:registry) { FactoryGirl.create(:docker_registry) }
    let(:compute_resource) { FactoryGirl.create(:docker_cr) }
    let(:image_search_service) { ForemanDocker::ImageSearch.new }
    let(:wizard_state) do
      DockerContainerWizardState.create
    end
    let(:preliminary) do
      DockerContainerWizardStates::Preliminary.create(
        compute_resource: compute_resource,
        wizard_state: wizard_state
      )
    end

    subject do
      Image.new(
        repository_name: image,
        tag: tags.first,
        wizard_state: wizard_state
      )
    end

    setup do
      ForemanDocker::ImageSearch.any_instance.unstub(:available?)
      wizard_state.preliminary = preliminary
      Service::RegistryApi.stubs(:docker_hub).returns(docker_hub)
    end

    describe 'it validates that the image is available' do
      test 'validates via the image_search_service' do
        DockerContainerWizardStates::Image.any_instance
                                          .stubs(:image_search_service)
                                          .returns(image_search_service)
        available = [true, false].sample
        image_search_service.expects(:available?)
                            .with("#{image}:#{tags.first}").at_least_once
                            .returns(available)
        assert_equal available, subject.valid?
      end

      context 'when no registy is set' do
        test 'it queries the compute_resource and docker_hub' do
          compute_resource.expects(:image).with(image).at_least_once
                          .returns(image)
          compute_resource.expects(:tags_for_local_image).at_least_once
                          .with(image, tags.first)
                          .returns([])
          docker_hub.expects(:tags).at_least_once
                    .returns([])

          subject.validate
        end
      end

      context 'when a registy is set' do
        setup do
          subject.stubs(:registry_id).returns(registry.id)
          DockerRegistry.expects(:find).with(registry.id)
                        .returns(registry)
        end

        test 'it queries the compute_resource and registry' do
          compute_resource.expects(:image).with(image).at_least_once
                          .returns(image)
          compute_resource.expects(:tags_for_local_image).at_least_once
                          .with(image, tags.first)
                          .returns([])
          docker_hub.expects(:tags).never
          registry.api.expects(:tags).with(image, tags.first).at_least_once
                  .returns([])

          subject.validate
        end
      end
    end
  end
end
