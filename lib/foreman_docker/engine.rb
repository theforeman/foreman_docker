require 'fast_gettext'
require 'gettext_i18n_rails'
require 'fog/fogdocker'
require 'wicked'
require 'docker'
require 'deface'

module ForemanDocker
  # Inherit from the Rails module of the parent app (Foreman), not the plugin.
  # Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine
    engine_name 'foreman_docker'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]

    initializer 'foreman_docker.load_app_instance_data' do |app|
      ForemanDocker::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer "foreman_docker.assets.precompile" do |app|
      app.config.assets.precompile += %w(foreman_docker/autocomplete.css
                                         foreman_docker/terminal.css
                                         foreman_docker/image_step.js)
    end

    initializer 'foreman_docker.configure_assets', :group => :assets do
      SETTINGS[:foreman_docker] =
        { :assets => { :precompile => ['foreman_docker/autocomplete.css',
                                       'foreman_docker/terminal.css',
                                       'foreman_docker/image_step.js'] } }
    end

    initializer 'foreman_docker.register_gettext', :after => :load_config_initializers do
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_docker'

      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer 'foreman_docker.register_plugin', :before => :finisher_hook do
      Foreman::Plugin.register :foreman_docker do
        requires_foreman '>= 1.11'
        compute_resource ForemanDocker::Docker

        sub_menu :top_menu, :containers_menu, :caption => N_('Containers'),
                                              :after => :monitor_menu do
          menu :top_menu, :containers,    :caption => N_('All containers'),
                                          :url_hash => { :controller => :containers,
                                                         :action => :index }
          menu :top_menu, :new_container, :caption => N_('New container'),
                                          :url_hash => { :controller => :containers,
                                                         :action => :new }
          menu :top_menu, :registries, :caption => N_('Registries'),
                                       :url_hash => { :controller => :registries,
                                                      :action => :index }
        end

        security_block :containers do
          permission :view_containers,
                     { :containers          => [:index, :show],
                       :'api/v2/containers' => [:index, :show, :logs] },
                     :resource_type => 'Container'
          permission :commit_containers, { :containers => [:commit] },
                     :resource_type => 'Container'
          permission :create_containers,
                     { :'containers/steps'  => [:show, :update],
                       :containers          => [:new],
                       :'api/v2/containers' => [:create, :power] },
                     :resource_type => 'Container'
          permission :destroy_containers,
                     { :containers          => [:destroy],
                       :'api/v2/containers' => [:destroy] },
                     :resource_type => 'Container'
          permission :power_compute_resources_vms,
                     { :containers          => [:power],
                       :'api/v2/containers' => [:create, :power] },
                     :resource_type => 'ComputeResource'
        end

        security_block :registries do
          permission :view_registries,
                     { :registries => [:index, :show],
                       :'api/v2/registries' => [:index, :show] },
                     :resource_type => 'DockerRegistry'
          permission :create_registries,
                     { :registries  => [:new, :create, :update, :edit],
                       :'api/v2/registries' => [:create, :update] },
                     :resource_type => 'DockerRegistry'
          permission :destroy_registries,
                     { :registries => [:destroy],
                       :'api/v2/registries' => [:destroy] },
                     :resource_type => 'DockerRegistry'
        end

        security_block :image_search do
          permission :search_repository_image_search,
                     { :image_search => [:auto_complete_repository_name,
                                         :auto_complete_image_tag,
                                         :search_repository] },
                     :resource_type => 'Docker/ImageSearch'
        end

        # apipie API documentation
        # Only available in 1.8, otherwise it has to be in the initializer below
        if SETTINGS[:version].to_s.include?('develop') ||
           Gem::Version.new(SETTINGS[:version].notag) >= Gem::Version.new('1.8')
          apipie_documented_controllers [
            "#{ForemanDocker::Engine.root}/app/controllers/api/v2/*.rb"]
        end
      end
    end

    initializer "foreman_docker.apipie" do
      # this condition is here for compatibility reason to work with Foreman 1.4.x
      # Also need to handle the reverse of the 1.8 method above
      unless SETTINGS[:version].to_s.include?('develop') ||
             Gem::Version.new(SETTINGS[:version].notag) >= Gem::Version.new('1.8')
        if Apipie.configuration.api_controllers_matcher.is_a?(Array)
          Apipie.configuration.api_controllers_matcher <<
            "#{ForemanDocker::Engine.root}/app/controllers/api/v2/*.rb"
        end
      end
    end

    rake_tasks do
      load "#{ForemanDocker::Engine.root}/lib/foreman_docker/tasks/test.rake"
    end

    require 'fog/fogdocker/models/compute/server'
    require 'fog/fogdocker/models/compute/image'
    require 'fog/fogdocker/models/compute/images'
    require File.expand_path('../../../app/models/concerns/fog_extensions/fogdocker/server',
                             __FILE__)
    require File.expand_path('../../../app/models/concerns/fog_extensions/fogdocker/image',
                             __FILE__)
    require File.expand_path('../../../app/models/concerns/fog_extensions/fogdocker/images',
                             __FILE__)
    config.to_prepare do
      Fog::Compute::Fogdocker::Server.send(:include, ::FogExtensions::Fogdocker::Server)
      Fog::Compute::Fogdocker::Image.send(:include, ::FogExtensions::Fogdocker::Image)
      # Compatibility fixes - to be removed once 1.7 compatibility is no longer required
      Fog::Compute::Fogdocker::Images.send(:include, ::FogExtensions::Fogdocker::Images)
      ::Taxonomy.send(:include, ForemanDocker::TaxonomyExtensions)
    end
  end
end
