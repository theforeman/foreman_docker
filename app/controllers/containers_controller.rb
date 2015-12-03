class ContainersController < ::ApplicationController
  include ForemanDocker::FindContainer

  before_filter :find_container, :only => [:show, :commit, :power]

  def index
    @container_resources = allowed_resources
    if @container_resources.empty?
      warning('You need a Compute Resource of type Docker to start managing containers')
      redirect_to new_compute_resource_path
    end
  # This should only rescue Fog::Errors, but Fog returns all kinds of errors...
  rescue
    process_error
  end

  def new
    redirect_to wizard_state_step_path(:wizard_state_id => DockerContainerWizardState.create.id,
                                       :id => :preliminary)
  end

  def destroy
    if container_deletion
      process_success(:success_redirect => containers_path,
                      :success_msg => (_("Container %s is being deleted.") %
                                            @deleted_identifier))
    else
      process_error(:redirect => containers_path)
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def show
  end

  def commit
    ForemanDocker::Docker.get_container(@container).commit(:author  => params[:commit][:author],
                                                           :repo => params[:commit][:repo],
                                                           :tag => params[:commit][:tag],
                                                           :comment => params[:commit][:comment])

    process_success :success_redirect => :back,
                    :success_msg      => _("%{container} commit was successful") %
                      { :container => @container }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to commit %{container}: %{e}") %
      { :container => @container, :e => e }
  end

  def power
    compute_resource = @container.compute_resource
    @docker_container = compute_resource.find_vm_by_uuid(@container.uuid)
    run_container_action(@docker_container.ready? ? :stop : :start)
  end

  def run_container_action(action)
    if @docker_container.send(action)
      @docker_container.reload
      notice _("%{vm} is now %{vm_state}") %
        { :vm => @docker_container, :vm_state => @docker_container.state.capitalize }
      redirect_to containers_path(:id => @container.id)
    else
      error _("failed to %{action} %{vm}") % { :action => _(action), :vm => @docker_container }
      redirect_to :back
    end
    # This should only rescue Fog::Errors, but Fog returns all kinds of errors...
  rescue => e
    error _("Error - %{message}") % { :message => _(e.message) }
    redirect_to :back
  end

  private

  def action_permission
    case params[:action]
    when 'auto_complete_repository_name', 'auto_complete_tag', 'search_repository'
      :view
    when 'commit'
      :commit
    when 'power'
      :power_compute_resources_vms
    else
      super
    end
  end

  def current_permission
    if params[:action] == 'power'
      :power_compute_resources_vms
    else
      super
    end
  end

  def container_deletion
    # Unmanaged container - only present in Compute Resource
    if params[:compute_resource_id].present?
      @deleted_identifier = params[:id]
      destroy_compute_resource_vm(params[:compute_resource_id], params[:id])
    else # Managed container
      find_container
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
end
