module Containers
  class StepsController < ::ApplicationController
    include Wicked::Wizard

    steps :preliminary, :image, :configuration, :environment
    before_filter :find_container

    def show
      case step
      when :preliminary
        @container_resources = ComputeResource.select { |cr| cr.provider == 'Docker' }
      end
      render_wizard
    end

    # rubocop:disable Metrics/MethodLength
    def update
      case step
      when :preliminary
        @container.update_attribute(:compute_resource_id, params[:container][:compute_resource_id])
      when :image
        @container.update_attributes!(params[:container])
      when :configuration
        @container.update_attributes(params[:container])
      when :environment
        @container.update_attributes(params[:container])
        if (response = start_container)
          @container.uuid = response.id
        else
          process_error(:object => @container.compute_resource, :render => 'environment')
          return
        end
      end
      render_wizard @container
    end

    private

    def finish_wizard_path
      container_path(:id => params[:container_id])
    end

    def allowed_resources
      ComputeResource.authorized(:view_compute_resources)
    end

    def find_container
      @container = Container.find(params[:container_id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end

    def start_container
      @container.compute_resource.create_container(@container.parametrize)
    end
  end
end
