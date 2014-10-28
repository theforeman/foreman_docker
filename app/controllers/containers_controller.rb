# rubocop:disable Metrics/ClassLength
class ContainersController < ::ApplicationController
  before_filter :find_container, :only => [:show, :auto_complete_image, :auto_complete_image_tags,
                                           :search_image, :commit]
  before_filter :find_registry, :only => [:auto_complete_image, :auto_complete_image_tags,
                                          :search_image]

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
                      :success_msg      => (_("Container %s is being deleted.") %
                                            @deleted_identifier))
    else
      process_error(:redirect => containers_path)
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end

  def show
  end

  def auto_complete_image
    exist = if @registry.nil?
              @container.compute_resource.exist?(params[:search])
            else
              registry_auto_complete_image(params[:search])
            end
    render :text => exist.to_s
  end

  def registry_auto_complete_image(term)
    result = ::Service::RegistryApi.new(:url => @registry.url).search(term)
    registry_name = term.split('/').size > 1 ? term :
        'library/' + term
    result['results'].any? { |r| r['name'] == registry_name }
  end

  def auto_complete_image_tags
    # This is the format jQuery UI autocomplete expects
    tags = if @registry.nil?
             @container.compute_resource.tags(params[:search])
           else
             registry_auto_complete_image_tags(params[:search])
           end
    respond_to do |format|
      format.js do
        tags.map! { |tag| { :label => CGI.escapeHTML(tag), :value => CGI.escapeHTML(tag) } }
        render :json => tags
      end
    end
  end

  def registry_auto_complete_image_tags(term)
    ::Service::RegistryApi.new(:url => @registry.url).list_repository_tags(term).keys
  end

  def commit
    Docker::Container.get(@container.uuid).commit(:author  => params[:commit][:author],
                                                  :repo    => params[:commit][:repo],
                                                  :tag     => params[:commit][:tag],
                                                  :comment => params[:commit][:comment])

    process_success :success_redirect => :back,
                    :success_msg      => _("%{container} commit was successful") %
                                         { :container => @container }
  rescue => e
    process_error :redirect => :back, :error_msg => _("Failed to commit %{container}: %{e}") %
                                                    { :container => @container, :e => e }
  end

  def search_image
    images = if @registry.nil?
               @container.compute_resource.search(params[:search])
             else
               r = ::Service::RegistryApi.new(:url => @registry.url).search(params[:search])
               r['results']
             end
    respond_to do |format|
      format.js { render :partial => 'image_search_results', :locals => { :images => images } }
    end
  end

  private

  def action_permission
    case params[:action]
    when 'auto_complete_image', 'auto_complete_image_tags', 'search_image'
      :view
    when 'commit'
      :commit
    else
      super
    end
  end

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

  # To be replaced by find_resource after 1.6 support is deprecated
  def find_container
    if params[:id].blank?
      not_found
      return
    end
    @container = Container.authorized("#{action_permission}_#{controller_name}".to_sym)
                          .find(params[:id])
  end

  def find_registry
    return if params[:registry_id].empty?
    @registry = DockerRegistry.authorized("#{action_permission}_#{controller_name}".to_sym)
    .find(params[:registry_id])
  end
end
