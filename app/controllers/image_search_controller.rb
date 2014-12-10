class ImageSearchController < ::ApplicationController
  before_filter :find_resource

  def auto_complete_repository_name
    render :text => (use_hub? ? hub_image_exists?(params[:search]) :
        registry_image_exists?(params[:search])).to_s
  end

  def auto_complete_image_tag
    # This is the format jQuery UI autocomplete expects
    tags = use_hub? ? hub_auto_complete_image_tags(params[:search]) :
        registry_auto_complete_image_tags(params[:search])
    respond_to do |format|
      format.js do
        tags.map! { |tag| { :label => CGI.escapeHTML(tag), :value => CGI.escapeHTML(tag) } }
        render :json => tags
      end
    end
  end

  def search_repository
    images = use_hub? ? hub_search_image(params[:search]) : registry_search_image(params[:search])
    respond_to do |format|
      format.js { render :partial => 'repository_search_results', :locals => { :images => images } }
    end
  end

  def use_hub?
    @registry.nil?
  end

  def hub_image_exists?(terms)
    @cr.exist?(terms)
  end

  def hub_auto_complete_image_tags(terms)
    @cr.tags(terms)
  end

  def hub_search_image(terms)
    @cr.search(terms)
  end

  def registry_image_exists?(term)
    result = ::Service::RegistryApi.new(:url => @registry.url).search(term)
    registry_name = term.split('/').size > 1 ? term :
        'library/' + term
    result['results'].any? { |r| r['name'] == registry_name }
  end

  def registry_auto_complete_image_tags(terms)
    ::Service::RegistryApi.new(:url => @registry.url).list_repository_tags(terms).keys
  end

  def registry_search_image(terms)
    r = ::Service::RegistryApi.new(:url => @registry.url).search(terms)
    r['results']
  end

  def action_permission
    case params[:action]
    when 'auto_complete_repository_name', 'auto_complete_image_tag', 'search_repository'
      :search_repository
    else
      super
    end
  end

  def find_resource
    if !params[:registry_id].empty?
      @registry = DockerRegistry.authorized(:view_registries).find(params[:registry_id])
    else
      @cr = ComputeResource.authorized(:view_compute_resources).find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    not_found
  end
end
