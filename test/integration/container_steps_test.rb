require 'test_helper'

class ContainerStepsTest < ActionDispatch::IntegrationTest
  test 'shows a link to a new compute resource if none is available'  do
    visit new_container_path
    assert has_selector?("div.alert", :text => 'Please add a new one')
  end

  test 'shows taxonomies tabs'  do
    visit new_container_path
    assert has_selector?("a", :text => 'Locations') if SETTINGS[:locations_enabled]
    assert has_selector?("a", :text => 'Organizations') if SETTINGS[:organizations_enabled]
  end
  # test 'clicking on search loads repositories' do
  #   Capybara.javascript_driver = :webkit
  #   container = FactoryGirl.create(:container)
  #   visit container_step_path(:container_id => container.id, :id => :repository)
  #   ComputeResource.any_instance.expects(:search).returns([{'name' => 'my_fake_repository_result',
  #                                                           'star_count' => 300,
  #                                                           'description' => 'fake repository'}])
  #   click_button 'search_repository'
  #   assert has_link? 'my_fake_repository_result'
  # end
end
