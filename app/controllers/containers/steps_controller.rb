module Containers
  class StepsController < ::ApplicationController
    include Wicked::Wizard
    include ForemanDocker::FindContainer

    steps :preliminary, :image, :configuration, :environment
    before_filter :build_state
    before_filter :set_form

    def show
      case step
      when :preliminary
        @container_resources = allowed_resources
      end
      render_wizard
    end

    def update
      case step
      when :environment
        @state.create_environment(params[:"docker_container_wizard_states_#{step}"])
        container = Service::Containers.start_container!(@state)
        if container
          return redirect_to container_path(container)
        else
          @environment = @state.environment
          process_error(:object => @state.environment, :render => 'environment')
          return
        end
      end
      render_wizard @state
    end

    private

    def build_state
      @state = DockerContainerWizardState.find(params[:wizard_state_id])
      @state.send(:"build_#{step}", params[:"docker_container_wizard_states_#{step}"])
    rescue ActiveRecord::RecordNotFound
      not_found
    end

    def set_form
      instance_variable_set("@#{step}", @state.send(:"#{step}") || @state.send(:"build_#{step}"))
    end
  end
end
