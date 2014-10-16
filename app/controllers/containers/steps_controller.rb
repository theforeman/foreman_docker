module Containers
  class StepsController < ::ApplicationController
    include Wicked::Wizard

    steps :preliminary, :image, :configuration, :environment
    before_filter :find_container

    def show
      case step
      when :preliminary
        @container_resources = ComputeResource.select { |cr| cr.provider == 'Docker' }
      when :image
      when :configuration
      when :environment
      end
      render_wizard
    end

    def update
      case step
      when :preliminary
        @container.update_attribute(:compute_resource_id, params[:container][:compute_resource_id])
      when :image
        @container.image = params[:image]
        @container.update_attributes(params[:container])
      when :configuration
        @container.update_attributes(params[:container])
      when :environment
        @container.update_attributes(params[:container])
        start_container
      end
      render_wizard @container
    end

    private

    def allowed_resources
      ComputeResource.authorized(:view_compute_resources)
    end

    def find_container
      @container = Container.find(params[:container_id])
    rescue ActiveRecord::RecordNotFound
      not_found
    end

    def start_container
      @container.compute_resource.create_vm(@container.parametrize)
    end
  end
end
