module ContainersHelper
  def managed?(container, resource)
    if uuids_in_resource(resource).include? container.identity
      '<span class="glyphicon glyphicon-check"></span>'.html_safe
    else
      '<span class="glyphicon glyphicon-unchecked"></span>'.html_safe
    end
  end

  def uuids_in_resource(resource)
    Container.where(:compute_resource_id => resource.id).pluck(:uuid)
  end
end
