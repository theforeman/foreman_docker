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
    field(f, 'container[registry_id]', :label => _("Registry")) do
      collection_select :container, :registry_id,
                        DockerRegistry.with_taxonomy_scope_override(@location, @organization)
                          .authorized(:view_registries),
                        :id, :name,
                        { :prompt => _("Select a registry") },
                        :class => "form-control", :disabled => f.object.repository_name.present?
    end
  end
end
