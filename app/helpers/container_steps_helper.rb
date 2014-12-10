module ContainerStepsHelper
  def container_wizard(step)
    wizard_header(
      step,
      _('Resource'),
      _('Image'),
      _('Configuration'),
      _('Environment')
    )
  end

  def select_registry(f)
    registries = DockerRegistry.with_taxonomy_scope_override(@location, @organization)
      .authorized(:view_registries)
    field(f, 'docker_container_wizard_states_image[registry_id]', :label => _("Registry")) do
      collection_select :wizard_states_image, :registry_id,
                        registries,
                        :id, :name,
                        { :prompt => _("Select a registry") },
                        :class => "form-control", :disabled => registries.size == 0
    end
  end
end
