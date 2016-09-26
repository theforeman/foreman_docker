class EnvironmentVariable < DockerParameter
  belongs_to :container, :foreign_key => :reference_id, :inverse_of => :environment_variables
  audited :associated_with => :container, :allow_mass_assignment => true
  validates :key, :uniqueness => { :scope => :reference_id }
end
