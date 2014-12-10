module Service
  class Containers
    def self.start_container!(wizard_state)
      ActiveRecord::Base.transaction do
        container = Container.new(wizard_state.container_attributes) do |r|
          # eagerly load environment variables
          state = DockerContainerWizardState.includes(:environment => [:environment_variables])
            .find(wizard_state.id)
          state.environment_variables.each do |e|
            r.environment_variables.build(
                :name => e.name, :value => e.value, :priority => e.priority)
          end
        end

        started = start_container(container)
        fail ActiveRecord::Rollback unless started

        container.save!
        destroy_wizard_state(wizard_state)

        container
      end
    end

    def self.start_container(container)
      started = container.compute_resource.create_container(container.parametrize)
      container.uuid = started.id if started
      started
    end

    def self.destroy_wizard_state(wizard_state)
      wizard_state.destroy
      DockerContainerWizardState.destroy_all(["updated_at < ?", (Time.now - 24.hours)])
    end
  end
end
