class Container < ActiveRecord::Base
  belongs_to :compute_resource
  belongs_to :image, :class_name => 'DockerImage', :foreign_key => 'docker_image_id'
  belongs_to :tag,   :class_name => 'DockerTag',   :foreign_key => 'docker_tag_id'

  attr_accessible :command, :image, :name, :compute_resource_id, :entrypoint,
                  :cpu_set, :cpu_shares, :memory, :tty, :attach_stdin,
                  :attach_stdout, :attach_stderr, :tag, :uuid

  def parametrize
    { :name => name, :image => tag.tag.blank? ? image.image_id : "#{image.image_id}:#{tag.tag}",
      :tty  => tty, :memory => memory,
      :entrypoint => entrypoint.try(:split), :cmd => command.try(:split),
      :attach_stdout => attach_stdout, :attach_stdout => attach_stdout,
      :attach_stderr => attach_stderr, :cpushares => cpu_shares, :cpuset => cpu_set }
  end

  def in_fog
    @fog_container ||= compute_resource.vms.get(uuid)
  end
end
