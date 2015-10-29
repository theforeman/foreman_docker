class CreateDockerRegistries < ActiveRecord::Migration
  def change
    create_table :docker_registries do |t|
      t.string :url
      t.string :name
      t.string :description
      t.timestamps
    end

    create_table :docker_image_docker_registries do |t|
      t.integer :docker_registry_id
      t.integer :docker_image_id
    end

    add_index :docker_image_docker_registries,
              [:docker_registry_id, :docker_image_id],
              :name => 'by_docker_image_and_registry',
              :unique => true
  end
end
