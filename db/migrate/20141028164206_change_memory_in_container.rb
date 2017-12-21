class ChangeMemoryInContainer < ActiveRecord::Migration[4.2]
  def up
    change_column :containers, :memory, :string
  end

  def down
    change_column :containers, :memory, :integer
  end
end
