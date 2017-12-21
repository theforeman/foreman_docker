class AddVerifySslOptionToDockerRegistries < ActiveRecord::Migration[4.2]
  def change
    add_column :docker_registries, :verify_ssl, :boolean, default: true
  end
end
