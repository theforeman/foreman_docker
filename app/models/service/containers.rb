module Service
  class Containers
    def errors
      @errors ||= []
    end

    def start_container!(wizard_state)
      ActiveRecord::Base.transaction do
        container = Container.new(wizard_state.container_attributes) do |r|
          # eagerly load environment variables and exposed ports configuration
          state = DockerContainerWizardState.includes(
            :environment => [:environment_variables, :exposed_ports]).find(wizard_state.id)

          load_environment_variables(state, r)
          load_exposed_ports(state, r)
        end

        Taxonomy.enabled_taxonomies.each do |taxonomy|
          container.send(:"#{taxonomy}=", wizard_state.preliminary.send(:"#{taxonomy}"))
        end

        fail ActiveRecord::Rollback unless pull_image(container) && start_container(container)

        container.save!
        destroy_wizard_state(wizard_state)
        container
      end
    end

    def pull_image(container)
      container.compute_resource.create_image(:fromImage => container.repository_pull_url)
    end

    def start_container(container)
      started = container.compute_resource.create_container(container.parametrize)
      if started
        container.uuid = started.id
      else
        errors << container.compute_resource.errors[:base]
      end
      started
    end

    def destroy_wizard_state(wizard_state)
      wizard_state.destroy
      DockerContainerWizardState.destroy_all(["updated_at < ?", (Time.now - 24.hours)])
    end

    def load_environment_variables(state, r)
      state.environment_variables.each do |environment_variable|
        r.environment_variables.build :name     => environment_variable.name,
                                      :value    => environment_variable.value,
                                      :priority => environment_variable.priority
      end
    end

    def load_exposed_ports(state, r)
      state.exposed_ports.each do |e|
        r.exposed_ports.build :name => e.name,
                              :value => e.value,
                              :priority => e.priority
      end
    end
  end
end
