require 'test_plugin_helper'

class DockerTagTest < ActiveSupport::TestCase
  test 'creating fails if no image is provided' do
    tag = FactoryGirl.build(:docker_tag, :image => nil)
    refute tag.valid?
    assert tag.errors.size >= 1
  end

  test 'creating succeeds if an image is provided' do
    tag       = FactoryGirl.build(:docker_tag)
    tag.image = FactoryGirl.build(:docker_image)

    assert tag.valid?
    assert tag.save
  end

  context 'validations' do
    test 'tag has to be present' do
      refute FactoryGirl.build(:docker_tag, :tag => '').valid?
    end

    test 'tag is not unique within image scope' do
      image          = FactoryGirl.create(:docker_image)
      tag            = FactoryGirl.create(:docker_tag, :image => image)
      duplicated_tag = FactoryGirl.build(:docker_tag,  :image => image, :tag => tag.tag)
      assert duplicated_tag.valid?
    end

    test 'tag is not unique for different images' do
      tag = FactoryGirl.create(:docker_tag)
      assert FactoryGirl.build(:docker_tag, :tag => tag.tag).valid?
    end
  end
end
