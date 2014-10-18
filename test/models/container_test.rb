require 'test_plugin_helper'

class ContainerTest < ActiveSupport::TestCase
  context 'update attributes' do
    setup do
      @container = FactoryGirl.create(:container)
    end

    test 'update image reuses previously created image' do
      assert_difference('DockerImage.count', 1) do
        @container.update_attribute(:image, "centos")
      end
      assert_equal "centos", @container.image.image_id
      refute_nil DockerImage.find_by_image_id("centos")

      assert_difference('DockerImage.count', 1) do
        @container.update_attribute(:image, "redis")
      end
      assert_equal "redis", @container.image.image_id

      assert_difference('DockerImage.count', 0) do
        @container.update_attribute(:image, "centos")
      end
    end

    test "update tag uses container's associated image" do
      @container.update_attribute(:image, 'centos')
      assert_difference('DockerTag.count', 1) do
        @container.update_attribute(:tag, 'latest')
      end

      assert_equal 'latest', @container.tag.tag
      assert_equal @container.tag.image, @container.image
    end
  end
end
