# This calls the main test_helper in Foreman-core
require 'test_helper'

def assert_row_button(index_path, link_text, button_text, dropdown = false)
  visit index_path
  within(:xpath, "//tr[contains(.,'#{link_text}')]") do
    find("i.caret").click if dropdown
    click_link(button_text)
  end
end

# Add plugin to FactoryGirl's paths
FactoryGirl.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryGirl.reload

def stub_image_existance(exists = true)
  Docker::Image.any_instance.stubs(:exist?).returns(exists)
  ForemanDocker::ImageSearch.any_instance.stubs(:available?).returns(exists)
end

def stub_registry_api
  Service::RegistryApi.any_instance.stubs(:get).returns({'results' => []})
  Docker::Image.stubs(:all).returns([])
end
