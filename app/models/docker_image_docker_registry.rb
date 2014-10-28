class DockerImageDockerRegistry < ActiveRecord::Base
  belongs_to :image, :class_name => DockerImage
  belongs_to :registry, :class_name => DockerRegistry
end
