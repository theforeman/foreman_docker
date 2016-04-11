module ContainersHelper
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
    taxonomies.map { |taxonomy| link_to(taxonomy) }.join(" ")
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
        link_to(_('Commit'), '#commit-modal',
                :'data-toggle' => 'modal',
                :class => 'btn btn-default')
      ),
      button_group(container_power_action(container.in_fog)),
      button_group(
        display_delete_if_authorized(
          hash_for_container_path(:id => container.id)
                                  .merge(:auth_object => container,
                                         :auth_action => 'destroy',
                                         :authorizer  => authorizer),
          :confirm => _("Delete %s?") % container.name,
          :class => 'btn btn-default')
      )
    )
  end

  def container_power_action(vm, authorizer = nil)
    if managed?(vm, @compute_resource)
      id = Container.find_by_uuid(vm.identity).id
      opts = hash_for_power_container_path(:id => id)
             .merge(:auth_object => @compute_resource,
                    :permission => 'power_compute_resources_vms',
                    :authorizer => authorizer)
    else
      opts = hash_for_power_compute_resource_vm_path(:compute_resource_id => @compute_resource,
                                                     :id => vm.identity)
             .merge(:auth_object => @compute_resource, :permission => 'power_compute_resources_vms',
                    :authorizer => authorizer)
    end
    html = if vm.ready?
             { :confirm => power_on_off_message(vm), :class => "btn btn-danger" }
           else
             { :class => "btn btn-info" }
           end

    display_link_if_authorized "Power #{action_string(vm)}", opts, html.merge(:method => :put)
  end

  def power_on_off_message(vm)
    _("Are you sure you want to power %{act} %{vm}?") % { :act => action_string(vm).downcase.strip,
                                                          :vm => vm }
  end

  def auto_complete_docker_search(name, val, options = {})
    addClass options, 'form-control'
    text_field_tag(name, val, options)
  end

  def processes(container)
    ForemanDocker::Docker.get_container(container).top
  end

  def logs(container, opts = {})
    ForemanDocker::Docker.get_container(container).logs(opts)
  end
end
