class DockerTag < ActiveRecord::Base
  belongs_to :docker_image

  attr_accessible :tag, :docker_image_id

  validates :docker_image_id, :presence => true
end
