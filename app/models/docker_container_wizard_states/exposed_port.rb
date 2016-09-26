module DockerContainerWizardStates
  class ExposedPort < DockerParameter
    belongs_to :environment,  :foreign_key => :reference_id, :inverse_of => :exposed_ports,
                              :class_name => 'DockerContainerWizardStates::Environment'
    validates :key,  :uniqueness => { :scope => :reference_id },
                      :numericality => { :only_integer => true,
                                         :greater_than => 0,
                                         :less_than_or_equal_to => 655_35 }
    validates :value, :presence => true,
                      :inclusion => { :in => %w(tcp udp) }
  end
end
