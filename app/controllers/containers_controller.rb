class ContainersController < ::ApplicationController
  def index
    @container_resources = allowed_resources.select { |cr| cr.provider == "Docker" }
  rescue => e
    process_error
  end

  def new
    @container = Container.create
    redirect_to container_steps_path(:container_id => @container.id)
  end

  private

  def allowed_resources
    ComputeResource.authorized(:view_compute_resources)
  end
end
