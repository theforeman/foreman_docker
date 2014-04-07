require 'fast_gettext'
require 'gettext_i18n_rails'
require 'fog'
require 'fog/fogdocker'

module ForemanDocker
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine

    initializer 'foreman_docker.register_gettext', :after => :load_config_initializers do |app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'docker'

      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_docker.register_plugin', :after=> :finisher_hook do |app|
      Foreman::Plugin.register :foreman_docker do
        requires_foreman '> 1.4'
        # Register docker compute resource in foreman
        compute_resource ForemanDocker::Docker
      end

    end

  end

  # extend fog docker server and image models.
  require 'fog/fogdocker/models/compute/server'
  require 'fog/fogdocker/models/compute/image'
  require File.expand_path('../../../app/models/concerns/fog_extensions/fogdocker/server', __FILE__)
  require File.expand_path('../../../app/models/concerns/fog_extensions/fogdocker/image', __FILE__)
  Fog::Compute::Fogdocker::Server.send(:include, ::FogExtensions::Fogdocker::Server)
  Fog::Compute::Fogdocker::Image.send(:include, ::FogExtensions::Fogdocker::Image)
end
