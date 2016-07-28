class EnvironmentVariable < Parameter
  belongs_to :container, :foreign_key => :reference_id, :inverse_of => :environment_variables
  audited :except => [:priority], :associated_with => :container, :allow_mass_assignment => true
  validates :name, :uniqueness => { :scope => :reference_id }
end
