class CreateDockerImages < ActiveRecord::Migration
  def up
    create_table :docker_images do |t|
      t.string  :image_id
      t.integer :size
      t.timestamps
    end

    create_table :docker_tags do |t|
      t.string  :tag
      t.references :docker_image, :null => false
      t.timestamps
    end
    add_foreign_key :docker_tags, :docker_images,
                    :column => :docker_image_id

    remove_column :containers, :image
    remove_column :containers, :tag
    add_column :containers, :docker_image_id, :integer
    add_column :containers, :docker_tag_id, :integer
    add_foreign_key :containers, :docker_images,
                    :column => :docker_image_id
    add_foreign_key :containers, :docker_tags,
                    :column => :docker_tag_id
  end

  def down
    drop_table :docker_images
    drop_table :docker_tags

    add_column :containers, :image, :string
    add_column :containers, :tag, :string
    remove_column :containers, :docker_image_id
    remove_column :containers, :docker_tag_id
  end
end
