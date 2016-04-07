require 'test_plugin_helper'

class ContainerTest < ActiveSupport::TestCase
  should belong_to(:compute_resource)
  should belong_to(:registry)
  should have_many(:environment_variables)
  should have_many(:dns)
  should have_many(:exposed_ports)
  should validate_uniqueness_of(:name)
end
