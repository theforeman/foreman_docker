class ContainersController < ::ApplicationController
  def index
    @container_resources = allowed_resources.select { |cr| cr.provider == 'Docker' }
    if @container_resources.empty?
      warning('You need a Compute Resource of type Docker to start managing containers')
      redirect_to new_compute_resource_path
    end
  # This should only rescue Fog::Errors, but Fog returns all kinds of errors...
  rescue
    process_error
  end

  def new
    @container = Container.create
    redirect_to container_step_path(:container_id => @container.id, :id => :preliminary)
  end

  private

  def allowed_resources
    ComputeResource.authorized(:view_compute_resources)
  end
end
