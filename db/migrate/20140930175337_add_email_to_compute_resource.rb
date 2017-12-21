class AddEmailToComputeResource < ActiveRecord::Migration[4.2]
  def change
    add_column :compute_resources, :email, :string
  end
end
