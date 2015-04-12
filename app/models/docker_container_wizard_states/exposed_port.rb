module DockerContainerWizardStates
  class ExposedPort < Parameter
    # The Parameter class from which ExposedPort class inherits,validates for the
    # presence of an  associated domain, operating system, host or host group. We
    # will have to reset those validations for the  ExposedPort class as  they do
    # not make any sense for the context in which this class is being used here.
    ExposedPort.reset_callbacks(:validate)

    belongs_to :environment,  :foreign_key => :reference_id, :inverse_of => :exposed_ports,
                              :class_name => 'DockerContainerWizardStates::Environment'
    validates :name,  :uniqueness => { :scope => :reference_id },
                      :numericality => { :only_integer => true,
                                         :greater_than => 0,
                                         :less_than_or_equal_to => 655_35 }
    validates :value, :presence => true,
                      :inclusion => { :in => %w(tcp udp) }
  end
end
