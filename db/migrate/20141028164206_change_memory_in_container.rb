class ChangeMemoryInContainer < ActiveRecord::Migration
  def up
    change_column :containers, :memory, :string
  end

  def down
    change_column :containers, :memory, :integer
  end
end
