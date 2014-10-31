class Container < ActiveRecord::Base
  include Authorizable

  belongs_to :compute_resource
  belongs_to :image, :class_name => 'DockerImage', :foreign_key => 'docker_image_id'
  belongs_to :tag,   :class_name => 'DockerTag',   :foreign_key => 'docker_tag_id'

  attr_accessible :command, :image, :name, :compute_resource_id, :entrypoint,
                  :cpu_set, :cpu_shares, :memory, :tty, :attach_stdin,
                  :attach_stdout, :attach_stderr, :tag, :uuid

  def parametrize
    { 'name'  => name, # key has to be lower case to be picked up by the Docker API
      'Image' => tag.tag.blank? ? image.image_id : "#{image.image_id}:#{tag.tag}",
      'Tty'          => tty,                    'Memory'       => memory,
      'Entrypoint'   => entrypoint.try(:split), 'Cmd'          => command.try(:split),
      'AttachStdout' => attach_stdout,          'AttachStdin'  => attach_stdin,
      'AttachStderr' => attach_stderr,          'CpuShares'    => cpu_shares,
      'Cpuset'       => cpu_set }
  end

  def in_fog
    @fog_container ||= compute_resource.vms.get(uuid)
  end
end
