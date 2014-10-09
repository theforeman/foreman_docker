class Container < ActiveRecord::Base
  belongs_to :compute_resource

  attr_accessible :command, :image, :name, :compute_resource_id, :tag, :entrypoint,
                  :cpu_set, :cpu_shares, :memory, :tty, :attach_stdin,
                  :attach_stdout, :attach_stderr

  def parametrize
    { :name => name, :cmd => [command], :image => image, :tty => tty,
      :attach_stdout => attach_stdout, :attach_stdout => attach_stdout,
      :attach_stderr => attach_stderr, :cpushares => cpu_shares, :cpuset => cpu_set,
      :memory => memory }
  end
end
