class AddEmailToComputeResource < ActiveRecord::Migration
  def change
    add_column :compute_resources, :email, :string
  end
end
