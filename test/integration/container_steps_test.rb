require 'integration_test_helper'

class ContainerStepsTest < IntegrationTestWithJavascript
  let(:wizard_state) { DockerContainerWizardState.create! }
  let(:compute_resource) { FactoryBot.create(:docker_cr) }
  let(:registry) { FactoryBot.create(:docker_registry) }
  let(:image_search_service) { ForemanDocker::ImageSearch.new }
  let(:image_search_results) do
    [{ 'name' => 'my_fake_repository_result',
       'star_count' => 300,
       'description' => 'fake repository' }]
  end

  let(:preliminary) do
    DockerContainerWizardStates::Preliminary.create!(
      :wizard_state => wizard_state,
      :compute_resource => compute_resource
    )
  end

  setup do
    stub_image_existance
    stub_registry_api
    ImageSearchController.any_instance.stubs(:image_search_service)
                         .returns(image_search_service)
  end

  describe 'on preliminary step' do
    test 'it shows docker compute resources' do
      compute_resource.save
      visit wizard_state_step_path(:wizard_state_id => wizard_state, :id => :preliminary)
      assert_text compute_resource.name
    end

    context 'when no compute resources are available' do
      setup do
        ForemanDocker::Docker.destroy_all
      end

      test 'shows a link to a new compute resource if none is available' do
        visit wizard_state_step_path(:wizard_state_id => wizard_state, :id => :preliminary)
        assert has_selector?("div.alert", :text => 'Please add a new one')
      end
    end

    test 'shows taxonomies tabs' do
      visit wizard_state_step_path(:wizard_state_id => wizard_state, :id => :preliminary)
      assert has_selector?("a", :text => 'Locations') if SETTINGS[:locations_enabled]
      assert has_selector?("a", :text => 'Organizations') if SETTINGS[:organizations_enabled]
    end
  end

  describe 'on image step' do
    ['hub', 'registry'].each do |tab|
      describe "on #{tab} tab" do
        let(:image_field_id) { "#{tab}_docker_container_wizard_states_image_repository_name" }
        let(:tag_field_id) { "#{tab}_docker_container_wizard_states_image_tag" }

        setup do
          registry.save
          wizard_state.preliminary = preliminary
          visit wizard_state_step_path(:wizard_state_id => wizard_state, :id => :image)
          find("##{tab}_tab").click

          if tab == 'registry'
            find("#docker_container_wizard_states_image_registry_id option:last-child", :visible => false)
              .select_option
          end
        end

        test 'clicking on search loads repositories' do
          image_search_service.expects(:search).at_least(2)
                              .returns(image_search_results)
          fill_in image_field_id, :with => "fake"
          wait_for_ajax
          find("#search_repository_button_#{tab}").click
          wait_for_ajax
          assert_text 'my_fake_repository_result'
        end

        describe 'autcomplete' do
          describe 'for image name' do
            test 'entering text triggers autocomplete' do
              image_search_service.expects(:search)
                                  .returns(image_search_results)
              fill_in image_field_id, :with => 'fa'
              wait_for_ajax
              has_selector?('.ui-autocomplete a', :text => 'my_fake_repository_result')
            end

            if tab == 'registry'
              context 'when no registry is selected' do
                test 'it does not trigger a autocomplete' do
                  image_search_service.expects(:search).never
                  find("#docker_container_wizard_states_image_registry_id option:first-child", :visible => false).select_option
                  fill_in image_field_id, :with => 'fa'
                  wait_for_ajax
                  has_no_selector?('.ui-autocomplete a', :text => 'my_fake_repository_result')
                end
              end
            end
          end

          describe 'for tag' do
            let(:image_name) { 'fake' }
            let(:tag_snippet) { 'lat' }

            setup do
              fill_in image_field_id, :with => 'fake'
            end

            test 'it searches for tags' do
              image_search_service.expects(:search).at_least(2)
                                  .returns(['latest'])
              fill_in tag_field_id, :with => tag_snippet
              wait_for_ajax
              has_selector?('.ui-autocomplete a', :text => 'latest')
            end
          end
        end
      end
    end
  end
end
