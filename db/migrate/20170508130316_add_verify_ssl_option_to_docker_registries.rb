class AddVerifySslOptionToDockerRegistries < ActiveRecord::Migration
  def change
    add_column :docker_registries, :verify_ssl, :boolean, default: true
  end
end
