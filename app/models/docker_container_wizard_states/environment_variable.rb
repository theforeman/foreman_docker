module DockerContainerWizardStates
  class EnvironmentVariable < Parameter
    belongs_to :environment, :foreign_key => :reference_id, :inverse_of => :environment_variables,
                             :class_name => 'DockerContainerWizardStates::Environment'
    validates :name, :uniqueness => { :scope => :reference_id }
  end
end
