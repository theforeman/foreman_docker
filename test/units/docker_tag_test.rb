require 'test_plugin_helper'

class DockerTagTest < ActiveSupport::TestCase
  test 'creating fails if no image is provided' do
    tag = DockerTag.new(FactoryGirl.attributes_for(:docker_tag))
    refute tag.valid?
    assert tag.errors.size >= 1
  end

  test 'creating succeeds if an image is provided' do
    tag       = FactoryGirl.build(:docker_tag)
    tag.image = FactoryGirl.create(:docker_image)

    assert tag.valid?
    assert tag.save
  end
end
