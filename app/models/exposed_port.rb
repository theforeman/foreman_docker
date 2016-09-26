class ExposedPort < DockerParameter
  belongs_to :container, :foreign_key => :reference_id, :inverse_of => :exposed_ports
  audited :associated_with => :container, :allow_mass_assignment => true
  validates :key,  :uniqueness => { :scope => :reference_id }
  validates :key,  :numericality => { :only_integer => true,
                                       :greater_than => 0,
                                       :less_than_or_equal_to => 655_35,
                                       :message => "%{value} is not a valid port number" }

  validates :value, :presence => true,
                    :inclusion => { :in => %w(tcp udp),
                                    :message => "%{value} is not a valid protocol" }
end
