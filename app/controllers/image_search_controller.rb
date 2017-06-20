class ImageSearchController < ::ApplicationController
  def search_repository
    catch_network_errors do
      tags_enabled = params[:tags] || 'false'
      result = image_search_service.search(term: params[:search], tags: tags_enabled)

      respond_to do |format|
        format.js { render json: prepare_for_autocomplete(result) }
        format.html do
          render partial: 'repository_search_results', locals: { repositories: result }
        end
      end
    end
  end

  private

  def catch_network_errors
    yield
  rescue Docker::Error::NotFoundError => e
    # not an error
    logger.debug "image not found: #{e.backtrace}"
    render :js, :nothing => true
  rescue Docker::Error::DockerError, Excon::Errors::Error, SystemCallError => e
    render :js => _("An error occured during repository search: '%s'") % e.message,
           :status => 500
  end

  def action_permission
    case params[:action]
    when 'search_repository'
      :search_repository
    else
      super
    end
  end

  # This is the format jQuery UI autocomplete expects
  def prepare_for_autocomplete(tags)
    tags.map do |tag|
      tag = tag.is_a?(Hash) ? tag.fetch('name', tag) : tag
      tag = CGI.escapeHTML(tag)
      { :label => tag, :value => tag }
    end
  end

  def image_search_service
    @image_search_service ||= ForemanDocker::ImageSearch.new(*sources)
  end

  def sources
    if params[:registry] == 'hub'
      @registry ||= Service::RegistryApi.docker_hub
      @compute_resource ||= ComputeResource.authorized(:view_compute_resources).find(params[:id])
      [@registry, @compute_resource]
    elsif params[:registry] == 'registry' && params[:registry_id].present?
      @registry ||= DockerRegistry.authorized(:view_registries)
        .find(params[:registry_id]).api
      [@registry]
    end
  end
end
