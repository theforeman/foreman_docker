module ForemanDocker
  module ComputeResourceExtensions
    extend ActiveSupport::Concern

    included do
      def self.providers_requiring_url
        _("Docker, Libvirt, oVirt, OpenStack and Rackspace")
      end
    end
  end
end
