class AddUserCredentialsToDockerRegistries < ActiveRecord::Migration
  def change
    add_column :docker_registries, :username, :string
    add_column :docker_registries, :password, :string
  end
end
