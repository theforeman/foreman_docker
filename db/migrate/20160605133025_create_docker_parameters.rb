class CreateDockerParameters < ActiveRecord::Migration
  def change
    create_table :docker_parameters do |t|
      t.string :key, :limit => 255
      t.text  :value
      t.string :type, :limit => 255
      t.integer :reference_id
      t.timestamps
    end

    add_index :docker_parameters, [:type, :reference_id, :key], :unique => true
  end
end
