require 'test_plugin_helper'

module ForemanDocker
  class DockerTest < ActiveSupport::TestCase
    should validate_presence_of(:url)
    should allow_value('a@b.com').for(:email)
    should allow_value('').for(:email)
    should_not allow_value('abcb.com').for(:email)
    should_not allow_value('a').for(:email)
  end
end
