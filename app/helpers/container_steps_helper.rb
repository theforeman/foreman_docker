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
    field(f, 'image[registry_id]', :label => _("Registry")) do
      collection_select :image, :registry_id,
                        DockerRegistry.with_taxonomy_scope_override(@location, @organization)
                          .authorized(:view_registries),
                        :id, :name,
                        { :prompt => _("Select a registry") },
                        :class => "form-control", :disabled => f.object.image.present?
    end
  end
end
