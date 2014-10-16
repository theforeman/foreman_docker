require 'uri'

module ForemanDocker
  class Docker < ::ComputeResource
    validates :url, :format => { :with => URI.regexp }

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:image]
    end

    def supports_update?
      false
    end

    def provided_attributes
      super.merge(:mac => :mac)
    end

    # FIXME
    def max_cpu_count
      8
    end

    def max_memory
      16 * 1024 * 1024 * 1024
    end

    def available_images
      client.images
    end

    def image(id)
      client.image.get(id) || fail(ActiveRecord::RecordNotFound)
    end

    def provider_friendly_name
      'Docker'
    end

    def create_vm(args = {})
      options = vm_instance_defaults.merge(args)
      logger.debug("creating Docker with the following options: #{options.inspect}")
      client.servers.create options
    rescue Fog::Errors::Error => e
      logger.debug "Fog error: #{e.message}\n " + e.backtrace.join("\n ")
      errors.add(:base, e.message.to_s)
      false
    end

    def vm_instance_defaults
      ActiveSupport::HashWithIndifferentAccess.new('name' => "foreman_#{Time.now.to_i}",
                                                   'cmd' => ['/bin/bash'])
    end

    def test_connection(options = {})
      super
      client
    # This should only rescue Fog::Errors, but Fog returns all kinds of errors...
    rescue => e
      errors[:base] << e.message
    end

    protected

    def bootstrap(args)
      client.servers.bootstrap vm_instance_defaults.merge(args.to_hash)
    rescue Fog::Errors::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def client
      @client ||= ::Fog::Compute.new(
          :provider         => 'fogdocker',
          :docker_username  => user,
          :docker_password  => password,
          :docker_email     => email,
          :docker_url       => url
      )
    end

    def api_version
      @api_version ||= client.send(:client).api_version
    end
  end
end
