module Api
  module V2
    class RegistriesController < ::Api::V2::BaseController
      before_filter :find_resource, :except => %w(index create)

      resource_description do
        resource_id 'registries'
        api_version 'v2'
        api_base_url '/docker/api/v2'
      end

      def_param_group :registry do
        param :registry, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param_group :taxonomies, ::Api::V2::BaseController
          param :url, String, :required => true
          param :description, String
          param :username, String
          param :password, String
        end
      end

      api :GET, '/registries/', N_('List all docker registries')
      param_group :search_and_pagination, ::Api::V2::BaseController
      def index
        @registries = DockerRegistry.search_for(params[:search], :order => params[:order])
                      .paginate(:page => params[:page])
      end

      api :GET, '/registries/:id', N_("Show a docker registry")
      param :id, :identifier, :required => true
      def show
      end

      api :POST, '/registries/', N_('Create a docker registry')
      param_group :registry, :as => :create
      def create
        @registry = DockerRegistry.new(params[:registry])
        process_response @registry.save
      end

      api :PUT, '/registries/:id', N_('Update a docker registry')
      param :id, :identifier, :required => true
      param_group :registry, :as => :update
      def update
        process_response @registry.update_attributes(params[:registry])
      end

      api :DELETE, '/registries/:id/', N_('Delete a docker registry')
      param :id, :identifier, :required => true
      def destroy
        process_response @registry.destroy
      end

      private

      def resource_class
        DockerRegistry
      end

      def docker_registry_url(registry)
        registry_url(registry)
      end
    end
  end
end
