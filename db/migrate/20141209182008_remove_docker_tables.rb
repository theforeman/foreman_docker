class RemoveDockerTables < ActiveRecord::Migration
  class DockerImage
  end

  class DockerTag
  end

  def up
    change_table :containers do |t|
      t.string :repository_name
      t.string :tag
      t.belongs_to :registry
    end

    Container.reset_column_information
    Container.all do |container|
      image = DockerImage.find(container.docker_image_id)
      container.update_attribute(:repository_name, image.image_id)

      tag = DockerTag.find(container.docker_tag_id)
      container.update_attribute(:tag, tag.tag)
    end

    if foreign_key_exists?(:containers, :name => :containers_docker_image_id_fk)
      remove_foreign_key :containers, :name => :containers_docker_image_id_fk
    end
    if foreign_key_exists?(:containers, :name => :containers_docker_tag_id_fk)
      remove_foreign_key :containers, :name => :containers_docker_tag_id_fk
    end

    remove_reference :containers, :docker_image, :foreign_key => true
    remove_reference :containers, :docker_tag, :foreign_key => true

    # these tables might have foreign keys from plugins like katello so use cascade
    cascade_drop(:docker_images)
    cascade_drop(:docker_tags)
    cascade_drop(:docker_image_docker_registries)
  end

  def down
    remove_column :containers, :repository_name
    remove_column :containers, :registry_id
    remove_column :containers, :tag
    add_column :containers, :docker_image_id, :integer
    add_column :containers, :docker_tag_id, :integer

    create_table :docker_images do |t|
      t.string  :image_id
      t.integer :size
      t.timestamps
    end
    create_table :docker_tags do |t|
      t.string :tag
      t.references :docker_image, :null => false
      t.timestamps
    end
    create_table :docker_image_docker_registries do |t|
      t.integer :id
      t.integer :docker_registry_id
      t.integer :docker_image_id
    end
  end

  def cascade_drop(table_name)
    case connection.adapter_name.downcase.to_sym
    when :mysql, :mysql2
      execute "SET FOREIGN_KEY_CHECKS=0"
      execute "DROP TABLE #{table_name}"
      execute "SET FOREIGN_KEY_CHECKS=1"
    when :pg, :postgresql
      execute "DROP TABLE #{table_name} CASCADE"
    when :sqlite
      execute "DROP TABLE #{table_name}"
    else
      fail NotImplementedError, "Unknown adapter type '#{connection.adapter_name.downcase.to_sym}'"
    end
  end
end
