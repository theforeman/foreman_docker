# module ForemanDocker
module Api
  module V2
    class ContainersController < ::Api::V2::BaseController
      before_filter :find_resource, :except => %w(index create)

      resource_description do
        resource_id 'containers'
        api_version 'v2'
        api_base_url '/docker/api/v2'
      end

      api :GET, '/containers/', N_('List all containers')
      api :GET, '/compute_resources/:compute_resource_id/containers/',
          N_('List all containers on a compute resource')
      param :compute_resource_id, :identifier
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        if params[:compute_resource_id].present?
          scoped = Container.where(:compute_resource_id => params[:compute_resource_id])
        else
          scoped = Container.where(nil)
        end
        @containers = scoped.search_for(params[:search], :order => params[:order])
                      .paginate(:page => params[:page])
      end

      api :GET, '/containers/:id/', N_('Show a container')
      api :GET, '/compute_resources/:compute_resource_id/containers/:id',
          N_('Show container on a compute resource')
      param :id, :identifier, :required => true
      param :compute_resource_id, :identifier

      def show
      end

      def_param_group :container do
        param :container, Hash, :required => true, :action_aware => true do
          param :name, String
          param_group :taxonomies, ::Api::V2::BaseController
          param :compute_resource_id, :identifier, :required => true
          param :registry_id, :identifier, :desc => N_('Registry this container will have to ' +
                                                        'use to get the image')
          param :repository_name, String, :required => true,
                                          :desc => N_('Name of the repository to use ' +
                                                       'to create the container. e.g. centos')
          param :tag, String, :required => true,
                              :desc => N_('Tag to use to create the container. e.g. latest')
          param :tty, :bool
          param :entrypoint, String
          param :command, String, :required => true
          param :memory, String
          param :cpu_shares, :number
          param :cpu_set, String
          param :environment_variables, Hash
          param :attach_stdout, :bool
          param :attach_stdin, :bool
          param :attach_stderr, :bool
          param :capsule_id, :identifier, :desc => N_('The capsule this container will have to ' +
                                                       'use to get the image. Relevant for images ' +
                                                       'retrieved from katello registry.')
        end
      end

      api :POST, '/containers/', N_('Create a container')
      api :POST, '/compute_resources/:compute_resource_id/containers/',
          N_('Create container on a compute resource')
      param_group :container, :as => :create

      def create
        service = Service::Containers.new
        @container = service.start_container!(set_wizard_state)
        if service.errors.any?
          render :json => { :errors => service.errors,
                            :full_messages => service.full_messages
                          },
                 :status => :unprocessable_entity
        else
          set_container_taxonomies
          process_response @container.save
        end
      rescue ActiveModel::MassAssignmentSecurity::Error => e
        render :json => { :error  => _("Wrong attributes: %s") % e.message },
               :status => :unprocessable_entity
      end

      api :DELETE, '/containers/:id/', N_('Delete a container')
      api :DELETE, '/compute_resources/:compute_resource_id/containers/:id',
          N_('Delete container on a compute resource')
      param :id, :identifier, :required => true
      param :compute_resource_id, :identifier

      def destroy
        deleted_identifier = ForemanDocker::ContainerRemover.remove_unmanaged(
          @container.compute_resource_id,
          @container.uuid)

        if deleted_identifier
          process_response @container.destroy
        else
          render :json => { :error => 'Could not delete container on Docker host' }, :status => :precondition_failed
        end
      end

      api :GET, '/containers/:id/logs', N_('Show container logs')
      api :GET, '/compute_resources/:compute_resource_id/containers/:id/logs',
          N_('Show logs from a container on a compute resource')
      param :id, :identifier, :required => true
      param :compute_resource_id, :identifier
      param :stdout, :bool
      param :stderr, :bool
      param :tail,   Fixnum, N_('Number of lines to tail. Default: 100')

      def logs
        render :json => { :logs => Docker::Container.get(@container.uuid)
          .logs(:stdout => (params[:stdout] || true),
                :stderr => (params[:stderr] || false),
                :tail   => (params[:tail] || 100)) }
      end

      api :PUT, '/containers/:id/power', N_('Run power operation on a container')
      api :PUT, '/compute_resources/:compute_resource_id/containers/:id/power',
          N_('Run power operation on a container on a compute resource')
      param :id, :identifier, :required => true
      param :compute_resource_id, :identifier
      param :power_action, String,
            :required => true,
            :desc     => N_('power action, valid actions are (start), (stop), (status)')

      def power
        power_actions = %(start stop status)
        if power_actions.include? params[:power_action]
          response = if params[:power_action] == 'status'
                       { :running => @container.in_fog.ready? }
                     else
                       { :running => @container.in_fog.send(params[:power_action]) }
                     end
          render :json => response
        else
          render :json =>
            { :error => _("Unknown method: available power operations are %s") %
              power_actions.join(', ') }, :status => :unprocessable_entity
        end
      end

      private

      def wizard_properties
        wizard_props = { :preliminary => [:compute_resource_id],
                         :image => [:registry_id, :repository_name, :tag],
                         :configuration => [:name, :command, :entrypoint, :cpu_set,
                                            :cpu_shares, :memory],
                         :environment => [:tty, :attach_stdin, :attach_stdout,
                                          :attach_stderr] }
        if DockerContainerWizardStates::Image.attribute_names.include?("capsule_id")
          wizard_props[:image] << :capsule_id
        end
        wizard_props
      end

      def set_wizard_state
        wizard_state = DockerContainerWizardState.create
        wizard_properties.each do |step, properties|
          property_values = properties.each_with_object({}) do |property, values|
            values[:"#{property}"] = params[:container][:"#{property}"]
          end
          wizard_state.send(:"create_#{step}", property_values)
        end

        if params[:container][:environment_variables].present?
          wizard_state.environment.environment_variables =
            params[:container][:environment_variables]
        end
        wizard_state.tap(&:save)
      end

      def set_container_taxonomies
        Taxonomy.enabled_taxonomies.each do |taxonomy|
          if params[:container][:"#{taxonomy}"].present?
            @container.send(:"#{taxonomy}=", params[:container][:"#{taxonomy}"])
          end
        end
      end

      def action_permission
        case params[:action]
        when 'logs'
          :view
        when 'power'
          :edit
        else
          super
        end
      end
    end
  end
end
# end
