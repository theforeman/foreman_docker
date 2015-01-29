module ContainersHelper
  def managed_icon(container, resource)
    icon_text(managed?(container, resource) ? 'check' : 'unchecked')
  end

  def managed?(container, resource)
    uuids_in_resource(resource).include? container.identity
  end

  def uuids_in_resource(resource)
    @uuids_in_resource ||= {}
    @uuids_in_resource[resource.id] ||= Container.where(:compute_resource_id => resource.id)
                                        .pluck(:uuid)
  end

  def link_to_container(container, resource)
    link_to_if_authorized container.name[1..-1].titleize,
                          container_link_hash(container, resource)
  end

  def link_to_taxonomies(taxonomies)
    taxonomies.map do |taxonomy|
      link_to(taxonomy)
    end.join(' ')
  end

  def container_link_hash(container, resource)
    if managed?(container, resource)
      hash_for_container_path(:id => Container.find_by_uuid(container.identity).id)
    else
      hash_for_compute_resource_vm_path(:compute_resource_id => resource,
                                        :id                  => container.identity)
    end
  end

  def container_title_actions(container)
    @compute_resource = container.compute_resource
    title_actions(
        button_group(
          link_to(_('Commit'), '#commit-modal', :'data-toggle' => 'modal')
        ),
        button_group(vm_power_action(container.in_fog)),
        button_group(
          display_delete_if_authorized(
            hash_for_container_path(:id => container.id)
                                    .merge(:auth_object => container,
                                           :auth_action => 'destroy',
                                           :authorizer  => authorizer),
            :confirm     => _("Delete %s?") % container.name)
        )
    )
  end

  def auto_complete_docker_search(name, val, options = {})
    addClass options, 'form-control'
    text_field_tag(name, val, options)
  end

  def hub_url(image)
    if image['is_official']
      "https://registry.hub.docker.com/_/#{image['name']}"
    else
      "https://registry.hub.docker.com/u/#{image['name']}"
    end
  end
end
