class ExposedPort < Parameter
  # The Parameter class from which ExposedPort class inherits,validates for the
  # presence of an  associated domain, operating system, host or host group. We
  # will have to reset those validations for the  ExposedPort class as  they do
  # not make any sense for the context in which this class is being used here.
  ExposedPort.reset_callbacks(:validate)

  belongs_to :container, :foreign_key => :reference_id, :inverse_of => :exposed_ports
  audited :except => [:priority], :associated_with => :container, :allow_mass_assignment => true
  validates :name,  :uniqueness => { :scope => :reference_id }
  validates :name,  :numericality => { :only_integer => true,
                                       :greater_than => 0,
                                       :less_than_or_equal_to => 655_35,
                                       :message => "%{value} is not a valid port number" }

  validates :value, :presence => true,
                    :inclusion => { :in => %w(tcp udp),
                                    :message => "%{value} is not a valid protocol" }
end
