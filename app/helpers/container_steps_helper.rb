module ContainerStepsHelper
  def container_wizard(step)
    wizard_header(
      step,
      *wizard_steps.map { |s| s.to_s.humanize }
    )
  end

  def select_registry(f)
    registries = DockerRegistry.with_taxonomy_scope_override(@location, @organization)
                 .authorized(:view_registries)
    field(f, 'docker_container_wizard_states_image[registry_id]', :label => _("Registry")) do
      collection_select :docker_container_wizard_states_image, :registry_id,
                        registries,
                        :id, :name,
                        { :prompt => _("Select a registry") },
                        :class => "form-control", :disabled => registries.size == 0
    end
  end

  def last_step?
    step == wizard_steps.last
  end

  def taxonomy_icon(taxonomy)
    taxonomy == 'locations' ? 'globe' : 'briefcase'
  end
end
