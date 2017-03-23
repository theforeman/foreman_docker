module DockerContainerWizardStates
  class Image < ActiveRecord::Base
    self.table_name_prefix = 'docker_container_wizard_states_'
    belongs_to :wizard_state, :class_name => DockerContainerWizardState,
                              :foreign_key => :docker_container_wizard_state_id
    delegate :compute_resource_id, :to => :wizard_state
    delegate :compute_resource, :to => :wizard_state

    validates :tag,             :presence => true
    validates :repository_name, :presence => true
    validate :image_exists

    def name
      "#{repository_name}:#{tag}"
    end

    def registry_api
      if registry_id
        DockerRegistry.find(registry_id).api
      else
        Service::RegistryApi.docker_hub
      end
    end

    def sources
      [compute_resource, registry_api]
    end

    def image_search_service
      ForemanDocker::ImageSearch.new(*sources)
    end

    def image_exists
      return true if image_search_service.available?(name)
      error_msg = _("Container image %{image_name} is not available.") % {
        image_name: "#{name}",
      }
      errors.add(:image, error_msg)
    end
  end
end
