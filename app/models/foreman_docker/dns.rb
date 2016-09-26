require 'resolv'

module ForemanDocker
  class Dns < DockerParameter
    belongs_to :container, :foreign_key => :reference_id,
                           :inverse_of => :dns,
                           :class_name => "Container"

    audited :associated_with => :container, :allow_mass_assignment => true
    validates :key, :uniqueness => { :scope => :reference_id },
                     :format => {
                       :with => Regexp.union(Resolv::IPv4::Regex,
                                             Resolv::IPv6::Regex,
                                             /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}$/) }
  end
end
