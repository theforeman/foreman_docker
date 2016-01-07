module DockerContainerWizardStates
  class Configuration < ActiveRecord::Base
    self.table_name_prefix = 'docker_container_wizard_states_'
    belongs_to :wizard_state, :class_name => DockerContainerWizardState,
                              :foreign_key => :docker_container_wizard_state_id

    validates :command, :presence => true

    attr_accessible :name, :command, :entrypoint, :cpu_set, :cpu_shares, :memory, :wizard_state
  end
end
