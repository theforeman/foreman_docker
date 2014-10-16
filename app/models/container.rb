class Container < ActiveRecord::Base
  belongs_to :compute_resource
  belongs_to :docker_image
  belongs_to :docker_tag

  attr_accessible :command, :image, :name, :compute_resource_id, :entrypoint,
                  :cpu_set, :cpu_shares, :memory, :tty, :attach_stdin,
                  :attach_stdout, :attach_stderr, :tag

  def parametrize
    { :name => name, :cmd => [command], :image => docker_image.image_id, :tty => tty,
      :attach_stdout => attach_stdout, :attach_stdout => attach_stdout,
      :attach_stderr => attach_stderr, :cpushares => cpu_shares, :cpuset => cpu_set,
      :memory => memory }
  end

  def image
    docker_image.try(:image_id)
  end

  def image=(image_id)
    image = DockerImage.find_or_create_by_image_id!(image_id)
    self.docker_image_id = image.id
  end

  def tag
    docker_tag.try(:tag)
  end

  def tag=(tag_name)
    tag = DockerTag.find_or_create_by_tag_and_docker_image_id!(tag_name, docker_image_id)
    self.docker_tag_id = tag.id
  end
end
