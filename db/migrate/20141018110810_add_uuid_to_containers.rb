class AddUuidToContainers < ActiveRecord::Migration[4.2]
  def change
    add_column :containers, :uuid, :string
    add_index  :containers, [:uuid, :compute_resource_id]
  end
end
