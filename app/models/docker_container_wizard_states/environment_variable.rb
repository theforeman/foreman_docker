module DockerContainerWizardStates
  class EnvironmentVariable < DockerParameter
    belongs_to :environment, :foreign_key => :reference_id, :inverse_of => :environment_variables,
                             :class_name => 'DockerContainerWizardStates::Environment'
    validates :key, :uniqueness => { :scope => :reference_id }
  end
end
