module DockerContainerWizardStates
  class Environment < ActiveRecord::Base
    self.table_name_prefix = 'docker_container_wizard_states_'
    belongs_to :wizard_state, :class_name => DockerContainerWizardState

    has_many :environment_variables, :dependent  => :destroy, :foreign_key => :reference_id,
                                     :inverse_of => :environment,
                                     :class_name =>
                                       'DockerContainerWizardStates::EnvironmentVariable'

    has_many :exposed_ports,  :dependent  => :destroy, :foreign_key => :reference_id,
                              :inverse_of => :environment,
                              :class_name => 'DockerContainerWizardStates::ExposedPort'
    has_many :dns,  :dependent  => :destroy, :foreign_key => :reference_id,
                    :inverse_of => :environment,
                    :class_name => 'DockerContainerWizardStates::Dns'

    include ForemanDocker::ParameterValidators
    accepts_nested_attributes_for :environment_variables, :allow_destroy => true
    accepts_nested_attributes_for :exposed_ports, :allow_destroy => true
    accepts_nested_attributes_for :dns, :allow_destroy => true

  end
end
