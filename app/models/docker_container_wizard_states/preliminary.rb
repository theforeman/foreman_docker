module DockerContainerWizardStates
  class Preliminary < ActiveRecord::Base
    include Taxonomix

    self.table_name_prefix = 'docker_container_wizard_states_'
    belongs_to :wizard_state, :class_name => DockerContainerWizardState,
                              :foreign_key => :docker_container_wizard_state_id

    validates :compute_resource_id, :presence => true
  end
end
