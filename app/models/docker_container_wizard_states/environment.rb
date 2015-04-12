module DockerContainerWizardStates
  class Environment < ActiveRecord::Base
    self.table_name_prefix = 'docker_container_wizard_states_'
    belongs_to :wizard_state, :class_name => DockerContainerWizardState
    # Fix me:
    # Validations are off on this association as there's a bug in ::Parameter
    # that forces validation of reference_id. This will fail on new records as
    # validations are executed before parent and children records have been persisted.
    has_many :environment_variables, :dependent  => :destroy, :foreign_key => :reference_id,
                                     :inverse_of => :environment,
                                     :class_name =>
                                       'DockerContainerWizardStates::EnvironmentVariable',
                                     :validate => false
    include ::ParameterValidators

    has_many :exposed_ports,  :dependent  => :destroy, :foreign_key => :reference_id,
                              :inverse_of => :environment,
                              :class_name => 'DockerContainerWizardStates::ExposedPort',
                              :validate => true

    accepts_nested_attributes_for :environment_variables, :allow_destroy => true
    accepts_nested_attributes_for :exposed_ports, :allow_destroy => true

    def parameters_symbol
      :environment_variables
    end
  end
end
