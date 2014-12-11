class DockerContainerWizardState < ActiveRecord::Base
  has_one :preliminary, :class_name => DockerContainerWizardStates::Preliminary,
                        :dependent => :destroy, :validate => true, :autosave => true
  has_one :image, :class_name => DockerContainerWizardStates::Image,
                  :dependent => :destroy, :validate => true, :autosave => true
  has_one :configuration, :class_name => DockerContainerWizardStates::Configuration,
                          :dependent => :destroy, :validate => true, :autosave => true
  has_one :environment, :class_name => DockerContainerWizardStates::Environment,
                        :dependent => :destroy, :validate => true, :autosave => true

  delegate :compute_resource_id,   :to => :preliminary
  delegate :environment_variables, :to => :environment

  def container_attributes
    { :repository_name     => image.repository_name,
      :tag                 => image.tag,
      :registry_id         => image.registry_id,
      :katello             => image.katello?,
      :name                => configuration.name,
      :compute_resource_id => preliminary.compute_resource_id,
      :tty                 => environment.tty,
      :memory              => configuration.memory,
      :entrypoint          => configuration.entrypoint,
      :command             => configuration.command,
      :attach_stdout       => environment.attach_stdout,
      :attach_stdin        => environment.attach_stdin,
      :attach_stderr       => environment.attach_stderr,
      :cpu_shares          => configuration.cpu_shares,
      :cpu_set             => configuration.cpu_set
    }
  end
end
