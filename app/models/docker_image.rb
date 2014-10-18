class DockerImage < ActiveRecord::Base
  has_many :tags, :class_name => 'DockerTag', :foreign_key => 'docker_tag_id',
                  :dependent  => :destroy
  has_many :containers

  attr_accessible :image_id, :size
end
