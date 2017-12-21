class AddUserCredentialsToDockerRegistries < ActiveRecord::Migration[4.2]
  def change
    add_column :docker_registries, :username, :string
    add_column :docker_registries, :password, :string
  end
end
