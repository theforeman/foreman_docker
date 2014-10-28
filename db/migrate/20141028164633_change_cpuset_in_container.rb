class ChangeCpusetInContainer < ActiveRecord::Migration
  def up
    change_column :containers, :cpu_set, :string
  end

  def down
    change_column :containers, :cpu_set, :integer
  end
end
