require 'resolv'

module ForemanDocker
  class Dns < Parameter
    # The Parameter class from which this Dns class inherits,validates for the
    # presence of an associated domain,  operating system, host or host group.
    # We will have to reset those validations for the Dns class as they do not
    # make any sense for the context in which this class is being used here.
    ForemanDocker::Dns.reset_callbacks(:validate)

    belongs_to :container, :foreign_key => :reference_id,
                           :inverse_of => :dns,
                           :class_name => "Container"

    audited :except => [:priority], :associated_with => :container, :allow_mass_assignment => true
    validates :name, :uniqueness => { :scope => :reference_id },
                     :format => {
                       :with => Regexp.union(Resolv::IPv4::Regex,
                                             Resolv::IPv6::Regex,
                                             /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}$/) }
  end
end
