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

  def destroy
    return unless params[:compute_resource_id].present?
    destroy_as_compute_resource_vm
  end

  private

  def destroy_as_compute_resource_vm
    @container_resource = ComputeResource.authorized(:destroy_compute_resources_vms)
      .find(params[:compute_resource_id])
    if @container_resource.destroy_vm(params[:id])
      process_success(:success_redirect => containers_path,
                      :success_msg      => _('Container is being deleted.'))
    else
      process_error(:redirect => containers_path)
    end
  end

  def allowed_resources
    ComputeResource.authorized(:view_compute_resources)
  end
end
