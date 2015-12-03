class CreateWizardStates < ActiveRecord::Migration
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :docker_container_wizard_states, &:timestamps

    create_table :docker_container_wizard_states_preliminaries do |t|
      t.integer :compute_resource_id, :null => false
      t.references :docker_container_wizard_state, :null => false
      t.timestamps
    end

    create_table :docker_container_wizard_states_images do |t|
      t.integer :registry_id
      t.string :repository_name, :null => false
      t.string :tag, :null => false
      t.references :docker_container_wizard_state, :null => false
      t.timestamps
    end

    create_table :docker_container_wizard_states_configurations do |t|
      t.string :name
      t.string :command
      t.string :entrypoint
      t.integer :cpu_set
      t.float :cpu_shares
      t.string :memory
      t.references :docker_container_wizard_state, :null => false
      t.timestamps
    end

    create_table :docker_container_wizard_states_environments do |t|
      t.boolean :tty
      t.boolean :attach_stdin, :default => true
      t.boolean :attach_stdout, :default => true
      t.boolean :attach_stderr, :default => true
      t.references :docker_container_wizard_state, :null => false
      t.timestamps
    end
  end
end
