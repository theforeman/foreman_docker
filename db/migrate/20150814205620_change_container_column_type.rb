class ChangeContainerColumnType < ActiveRecord::Migration
  def up
    change_column :containers, :cpu_shares, :integer
    change_column :docker_container_wizard_states_configurations, :cpu_shares, :integer
    change_column :docker_container_wizard_states_configurations, :cpu_set, :string
  end

  def down
    change_column :containers, :cpu_shares, :float
    change_column :docker_container_wizard_states_configurations, :cpu_shares, :float
    change_column :docker_container_wizard_states_configurations, :cpu_set, :integer
  end
end
