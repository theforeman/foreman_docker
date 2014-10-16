class DockerImage < ActiveRecord::Base
  has_many :docker_tags, :dependent => :destroy
  has_many :containers

  attr_accessible :image_id, :size
end
