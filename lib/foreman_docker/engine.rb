require 'fast_gettext'
require 'gettext_i18n_rails'
require 'fog'
require 'fog/fogdocker'
require 'wicked'
require 'docker'

module ForemanDocker
  # Inherit from the Rails module of the parent app (Foreman), not the plugin.
  # Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine
    engine_name 'foreman_docker'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]

    initializer 'foreman_docker.load_app_instance_data' do |app|
      app.config.paths['db/migrate'] += ForemanDocker::Engine.paths['db/migrate'].existent
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

    initializer 'foreman_docker.register_plugin', :after => :finisher_hook do
      Foreman::Plugin.register :foreman_docker do
        requires_foreman '> 1.4'
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
          permission :view_containers,    :containers         => [:index, :show]
          permission :commit_containers,  :containers         => [:commit]
          permission :create_containers,  :'containers/steps' => [:show, :update],
                                          :containers         => [:new]
          permission :destroy_containers, :containers         => [:destroy]
        end

        security_block :registries do
          permission :view_registries,    :registries         => [:index, :show]
          permission :create_registries,  :registries         => [:new, :create, :update, :edit]
          permission :destroy_registries, :registries         => [:destroy]
        end

        security_block :image_search do
          permission :search_repository_image_search,
                     :image_search => [:auto_complete_repository_name,
                                       :auto_complete_image_tag,
                                       :search_repository]
        end
      end
    end

    rake_tasks do
      load "#{ForemanDocker::Engine.root}/lib/foreman_docker/tasks/test.rake"
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
