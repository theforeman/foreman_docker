class AddUuidToContainers < ActiveRecord::Migration
  def change
    add_column :containers, :uuid, :string
    add_index  :containers, [:uuid, :compute_resource_id]
  end
end
