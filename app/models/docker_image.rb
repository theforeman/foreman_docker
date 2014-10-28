class DockerImage < ActiveRecord::Base
  has_many :tags, :class_name => 'DockerTag', :foreign_key => 'docker_image_id',
                  :dependent  => :destroy
  has_many :containers
  has_many :docker_image_docker_registries
  has_many :registries, :class_name => 'DockerRegistry', :uniq => true,
           :through => :docker_image_docker_registries

  attr_accessible :image_id, :size

  validates :image_id, :presence => true, :uniqueness => true
end
