class MoveParametersToDockerParameters < ActiveRecord::Migration
  class FakeDockerParameter < ActiveRecord::Base
    self.table_name = 'docker_parameters'
  end

  class FakeParameter < ActiveRecord::Base
    self.table_name = 'parameters'
  end

  def up
  # All the  DockerContainerWizardStates::PARAMETER are temporary for the wizard step so no need to keep them
   docker_params = FakeParameter.unscoped.where(:type => ['EnvironmentVariable', 'ForemanDocker::Dns', 'ExposedPort'])
   docker_params.each do |param|
     DockerParameter.create(:key => param['name'], :value => param['value'], :reference_id => param['reference_id'], :type => param['type'])
   end
   docker_params.delete_all
  end

  def down
    docker_params = FakeDockerParameter.unscoped.where(:type => ['EnvironmentVariable', 'ForemanDocker::Dns', 'ExposedPort'])
    docker_params.each do |param|
      Parameter.create(:key => param['name'], :value => param['value'], :reference_id => param['reference_id'], :type => param['type'])
    end

    docker_params.delete_all
  end
end
