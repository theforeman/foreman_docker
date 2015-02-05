require 'test_plugin_helper'

class RegistryApiTest <  ActiveSupport::TestCase
  test "initialize handles username password info correctly" do
    uname = "tardis"
    password = "boo"
    url = "http://docker-who.gov"
    reg = Service::RegistryApi.new(:url => url,
                                   :user => uname,
                                   :password => password)
    assert reg.config[:url].include?(uname)
    assert reg.config[:url].include?(password)

    reg = Service::RegistryApi.new(:url => url)
    assert_equal url, reg.config[:url]
  end
end
