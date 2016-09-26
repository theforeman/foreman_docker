module Containers
  class StepsController < ::ApplicationController
    include Wicked::Wizard
    include ForemanDocker::FindContainer

    steps :preliminary, :image, :configuration, :environment

    before_filter :find_state
    before_filter :build_state, :only => [:update]
    before_filter :set_form, :only => [:show]

    def show
      @container_resources = allowed_resources if step == :preliminary
      render_wizard
    end

    def update
      if step == wizard_steps.last
        if process_resource!(@state).nil?
          render_wizard @state
        else
          params[:start_on_create] ? create_container : create_container(false)
        end
      else
        render_wizard @state
      end
    end

    private

    def find_state
      @state = DockerContainerWizardState.find(params[:wizard_state_id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end

    def build_state
      s = @state.send(:"build_#{step}", state_params)
      instance_variable_set("@docker_container_wizard_states_#{step}", s)
    end

    def docker_parameters_permited_params
      [:key, :reference_id, :value, :_destroy, :id]
    end

    def state_params
      attrs = case step
              when :preliminary
                [:wizard_state, :compute_resource_id]
              when :image
                [:repository_name, :tag, :wizard_state, :registry_id, :capsule_id, :katello]
              when :configuration
                [:name, :command, :entrypoint, :cpu_set, :cpu_shares, :memory, :wizard_state]
              when :environment
                [:tty, :docker_container_wizard_state_id,
                 :attach_stdin, :attach_stdout, :attach_stderr,
                 :exposed_ports_attributes => docker_parameters_permited_params,
                 :environment_variables_attributes => docker_parameters_permited_params,
                 :dns_attributes => docker_parameters_permited_params
                ]
              end

      params.require("docker_container_wizard_states_#{step}").permit(*attrs)
    end

    def set_form
      instance_variable_set(
        "@docker_container_wizard_states_#{step}",
        @state.send(:"#{step}") || @state.send(:"build_#{step}"))
    end

    def create_container(start = true)
      @state.send(:"create_#{step}", state_params)
      service = Service::Containers.new
      container = if start.is_a? TrueClass
                    service.start_container!(@state)
                  else
                    service.create_container!(@state)
                  end
      
      if container.present?
        process_success(:object => container, :success_redirect => container_path(container))
      else
        @docker_container_wizard_states_environment = @state.environment
        process_error(
          :redirect => containers_path,
          :error_msg => service.full_messages.join(','),
          :object => @state.environment)
      end
    end
  end
end
