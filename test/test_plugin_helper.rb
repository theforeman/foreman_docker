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
