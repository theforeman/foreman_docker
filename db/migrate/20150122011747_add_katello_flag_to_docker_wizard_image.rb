class AddKatelloFlagToDockerWizardImage < ActiveRecord::Migration
  def up
    add_column :docker_container_wizard_states_images, :katello, :boolean
  end

  def down
    remove_column :docker_container_wizard_states_images, :katello
  end
end
