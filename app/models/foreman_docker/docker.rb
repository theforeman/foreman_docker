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

    def max_memory
      16 * 1024 * 1024 * 1024
    end

    def max_cpu_count
      ::Docker.info['NCPU'] || 1
    end

    def available_images
      client.images.all
    end

    def local_images(filter = '')
      client # initialize Docker-Api
      ::Docker::Image.all('filter' => filter)
    end

    def tags_for_local_image(image)
      image.info['RepoTags'].map do |image_tag|
        _, tag = image_tag.split(':')
        tag
      end
    end

    def exist?(name)
      ::Docker::Image.exist?(name)
    end

    def image(id)
      client.image_get(id)
    end

    def tags(image_name)
      if exist?(image_name)
        tags_for_local_image(local_images(image_name).first)
      else
        # If image is not found in the compute resource, get the tags from the Hub
        hub_api_url = "https://index.docker.io/v1/repositories/#{image_name}/tags"
        JSON.parse(URI.parse(hub_api_url).read).map do |tag|
          tag['name']
        end
      end
    end

    def search(term = '')
      client.images.image_search(:term => term)
    end

    def provider_friendly_name
      'Docker'
    end

    def create_container(args = {})
      options = vm_instance_defaults.merge(args)
      logger.debug("Creating container with the following options: #{options.inspect}")
      docker_command do
        ::Docker::Container.create(options)
      end
    end

    def create_image(args = {})
      logger.debug("Creating docker image with the following options: #{args.inspect}")
      docker_command do
        ::Docker::Image.create(args)
      end
    end

    def vm_instance_defaults
      ActiveSupport::HashWithIndifferentAccess.new('name' => "foreman_#{Time.now.to_i}",
                                                   'Cmd' => ['/bin/bash'])
    end

    def console(uuid)
      test_connection
      container = ::Docker::Container.get(uuid)
      {
        :name       => container.info['Name'],
        'timestamp' => Time.now.utc,
        'output'    => container.logs(:stdout => true, :tail => 100)
      }
    end

    def test_connection(options = {})
      super
      client.present?
    # This should only rescue Fog::Errors, but Fog returns all kinds of errors...
    rescue => e
      errors[:base] << e.message
      false
    end

    protected

    def docker_command
      yield
    rescue Excon::Errors::Error, ::Docker::Error::DockerError => e
      logger.debug "Fog error: #{e.message}\n " + e.backtrace.join("\n ")
      errors.add(:base,
                 _("Error creating communicating with Docker. Check the Foreman logs: %s") %
                 e.message.to_s)
      false
    end

    def bootstrap(args)
      client.servers.bootstrap vm_instance_defaults.merge(args.to_hash)
    rescue Fog::Errors::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def client
      opts = {
        :provider => 'fogdocker',
        :docker_url => url
      }
      opts[:docker_username] = user if user.present?
      opts[:docker_password] = password if password.present?
      opts[:docker_email] = email if email.present?
      @client ||= ::Fog::Compute.new(opts)
    end

    def api_version
      @api_version ||= client.send(:client).api_version
    end
  end
end
