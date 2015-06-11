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
      s = @state.send(:"build_#{step}", params[:"docker_container_wizard_states_#{step}"])
      instance_variable_set("@docker_container_wizard_states_#{step}", s)
    end

    def set_form
      instance_variable_set(
          "@docker_container_wizard_states_#{step}",
          @state.send(:"#{step}") || @state.send(:"build_#{step}"))
    end

    def create_container(start = true)
      @state.send(:"create_#{step}", params[:"docker_container_wizard_states_#{step}"])
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
            :error_msg => service.errors.full_messages.join(','),
            :object => @state.environment,
            :render => 'environment')
      end
    end
  end
end
