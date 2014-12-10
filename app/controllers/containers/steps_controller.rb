module Containers
  class StepsController < ::ApplicationController
    include Wicked::Wizard

    steps :preliminary, :image, :configuration, :environment
    before_filter :find_state

    # rubocop:disable Metrics/CyclomaticComplexity
    def show
      case step
      when :preliminary
        @container_resources = allowed_resources.select { |cr| cr.provider == 'Docker' }
        @preliminary = @state.preliminary || @state.build_preliminary
      when :image
        @image = @state.image || @state.build_image
      when :configuration
        @configuration = @state.configuration || @state.build_configuration
      when :environment
        @environment = @state.environment || @state.build_environment
      end
      render_wizard
    end

    # rubocop:disable Metrics/MethodLength
    def update
      case step
      when :preliminary
        @state.create_preliminary!(params[:docker_container_wizard_states_preliminary])
      when :image
        @state.create_image!(params[:docker_container_wizard_states_image])
      when :configuration
        @state.create_configuration!(params[:docker_container_wizard_states_configuration])
      when :environment
        @state.create_environment!(params[:docker_container_wizard_states_environment])
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

    def allowed_resources
      ComputeResource.authorized(:view_compute_resources)
    end

    def find_state
      @state = DockerContainerWizardState.find(params[:wizard_state_id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end
  end
end
