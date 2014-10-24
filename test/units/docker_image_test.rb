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

  context 'validations' do
    test 'without image_id is invalid' do
      refute FactoryGirl.build(:docker_image, :image_id => '').valid?
    end

    test 'image_id has to be unique' do
      old_image = FactoryGirl.create(:docker_image)
      refute FactoryGirl.build(:docker_image, :image_id => old_image.image_id).valid?
    end
  end
end
