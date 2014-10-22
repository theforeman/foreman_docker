require 'test_plugin_helper'

class DockerImageTest < ActiveSupport::TestCase
  test 'destroy docker image with tags is successful' do
    tag = FactoryGirl.create(:docker_tag)
    image = FactoryGirl.create(:docker_image)
    image.tags << tag
    assert image.destroy
    refute DockerImage.exists?(image.id)
    refute DockerTag.exists?(tag.id)
  end
end
