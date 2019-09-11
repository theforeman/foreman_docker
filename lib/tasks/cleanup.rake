namespace :foreman_docker do
  desc 'Clean default data created by this plugin, this will permanently delete the data!'
  task :cleanup => :environment do
    puts 'Cleaning data...'

    User.as_anonymous_admin do
      puts '... deleting records from taxable_taxonomies'
      TaxableTaxonomy.where(:taxable_type => [ 'Container', 'DockerRegistry', 'Preliminary', 'ForemanDocker::Docker' ]).delete_all
      puts '... removing all host group associations to Docker compute resources'
      Hostgroup.where(:compute_resource_id => ForemanDocker::Docker.pluck(:id)).update_all("compute_resource_id = NULL")
      puts '... deleting filters'
      Filter.joins(:permissions).where('permissions.resource_type' => Foreman::Plugin.find(:foreman_docker).registered_permissions.map { |p, attrs| attrs[:resource_type] }.uniq!).destroy_all
      puts '... deleting permissions'
      Permission.where(:name => Foreman::Plugin.find(:foreman_docker).registered_permissions.map(&:first)).destroy_all
      puts '... deleting docker compute resources'
      ForemanDocker::Docker.destroy_all
      puts 'data from all tables deleted'
    end

    tables = [
      :containers,
      :docker_registries,
      :docker_container_wizard_states,
      :docker_container_wizard_states_preliminaries,
      :docker_container_wizard_states_images,
      :docker_container_wizard_states_configurations,
      :docker_container_wizard_states_environments,
      :docker_parameters
    ]
    tables.each do |table|
      puts "... dropping table #{table}"
      ActiveRecord::Migration.drop_table table
    end

    puts 'Clean up finished, you can now remove the plugin from your system'
  end
end

