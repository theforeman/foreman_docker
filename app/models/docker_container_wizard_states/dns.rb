require 'resolv'

module DockerContainerWizardStates
  class Dns < Parameter
    # The Parameter class from which this Dns class inherits,validates for the
    # presence of an associated domain,  operating system, host or host group.
    # We will have to reset those validations for the Dns class as they do not
    # make any sense for the context in which this class is being used here.
    Dns.reset_callbacks(:validate)

    belongs_to :environment,  :foreign_key => :reference_id,
                              :inverse_of => :dns,
                              :class_name => 'DockerContainerWizardStates::Environment'
    validates :name, :uniqueness => { :scope => :reference_id },
                     :format => {
                       :with => Regexp.union(Resolv::IPv4::Regex,
                                             Resolv::IPv6::Regex,
                                             /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}$/) }
  end
end
