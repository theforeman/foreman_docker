class AddComputeResourceIdToContainer < ActiveRecord::Migration
  def change
    add_column :containers, :compute_resource_id, :integer
  end
end
