class Container < ActiveRecord::Base
  belongs_to :compute_resource
  belongs_to :image, :class_name => 'DockerImage', :foreign_key => 'docker_image_id'
  belongs_to :tag,   :class_name => 'DockerTag',   :foreign_key => 'docker_tag_id'

  attr_accessible :command, :image, :name, :compute_resource_id, :entrypoint,
                  :cpu_set, :cpu_shares, :memory, :tty, :attach_stdin,
                  :attach_stdout, :attach_stderr, :tag, :uuid

  def parametrize
    { :name => name, :cmd => [command], :image => "#{image.image_id}:#{tag.tag}", :tty => tty,
      :attach_stdout => attach_stdout, :attach_stdout => attach_stdout,
      :attach_stderr => attach_stderr, :cpushares => cpu_shares, :cpuset => cpu_set,
      :memory => memory }
  end

  def image=(image_id)
    self[:docker_image_id] = DockerImage.find_or_create_by_image_id!(image_id).id
  end

  def tag=(tag_name)
    self[:docker_tag_id] = DockerTag
                          .find_or_create_by_tag_and_docker_image_id!(tag_name, image.id).id
  end

  # Do not delete even if it's not being used - this is a convenience for developers
  def in_fog
    compute_resource.vms.get(uuid)
  end
end
