class ContainersController < ::ApplicationController
  before_filter :find_resource, :only => [:show]

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
    if resource_deletion
      process_success(:success_redirect => containers_path,
                      :success_msg      => _("Container #{@deleted_identifier} is being deleted."))
    else
      process_error(:redirect => containers_path)
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def show
  end

  private

  def resource_deletion
    # Unmanaged container - only present in Compute Resource
    if params[:compute_resource_id].present?
      @deleted_identifier  = params[:id]
      destroy_compute_resource_vm(params[:compute_resource_id], params[:id])
    else # Managed container
      find_resource
      @deleted_identifier = @container.name

      destroy_compute_resource_vm(@container.compute_resource, @container.uuid) &&
      @container.destroy
    end
  end

  def destroy_compute_resource_vm(resource_id, uuid)
    @container_resource = ComputeResource.authorized(:destroy_compute_resources_vms)
                                         .find(resource_id)
    @container_resource.destroy_vm(uuid)
  rescue => error
    logger.error "#{error.message} (#{error.class})\n#{error.backtrace.join("\n")}"
    false
  end

  def allowed_resources
    ComputeResource.authorized(:view_compute_resources)
  end
end
